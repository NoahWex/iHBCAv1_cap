#!/usr/bin/env python3
"""
patch_hca_validation.py - Fix HCA Data Portal schema validation errors in obs
=============================================================================
Applies the validation fixes the HCA Tracker team flagged on the iHBCA v1
objects (2026-07), operating directly on the h5ad obs group via h5py without
loading X / layers into memory.

Fixes:
  1. Remove obs columns HCA does not collect. HCA does not store
     self_reported_ethnicity (privacy), so `self_reported_ethnicity_ontology_term_id`
     is dropped from obs.
  2. `library_preparation_batch` / `library_sequencing_run` must be a single
     identifier per cell. The assembly stamped donor-level, comma-joined values
     onto every cell (see build_sra_run_tables.py, which collapsed runs/batches
     to one row per donor). Each cell that resolves to a single value keeps it;
     comma-joined aggregates and the "unknown" placeholder are set to missing
     (NaN), per HCA guidance ("leave the value missing if not known").

Only the obs group is rewritten. X, layers, var, and uns (including cap_metadata)
are left untouched.

read_obs_from_h5ad / write_obs_to_h5ad are copied verbatim from patch_obs_h5py.py
so this script is self-contained (no repo package imports) and can run standalone
on HPC next to the object.

Usage:
  python patch_hca_validation.py --h5ad path/to/object.h5ad
"""

import argparse

import h5py
import numpy as np
import pandas as pd


# ---------------------------------------------------------------------------
# obs read/write (copied from patch_obs_h5py.py)
# ---------------------------------------------------------------------------
def _decode(arr):
    """Decode an h5py string array to python str, UTF-8 safe.

    numpy's .astype(str) on a bytes array uses ASCII and fails on UTF-8
    (e.g. an em-dash in a category). Decode explicitly instead.
    """
    a = np.asarray(arr)
    if a.dtype.kind == "S":
        return np.char.decode(a, "utf-8")
    if a.dtype.kind == "O":
        return np.array(
            [x.decode("utf-8") if isinstance(x, (bytes, bytearray)) else str(x) for x in a],
            dtype=object,
        )
    return a.astype(str)


def read_obs_from_h5ad(h5ad_path):
    """Read obs dataframe from h5ad without loading X/layers/obsm (UTF-8 safe)."""
    with h5py.File(h5ad_path, "r") as f:
        obs_group = f["obs"]

        index_col_name = obs_group.attrs.get("_index", "_index")
        if isinstance(index_col_name, bytes):
            index_col_name = index_col_name.decode()

        if index_col_name in obs_group:
            index = _decode(obs_group[index_col_name][()])
        elif "_index" in obs_group:
            index = _decode(obs_group["_index"][()])
        elif "__categories" in obs_group.attrs:
            index = _decode(obs_group["index"][()])
        else:
            index = np.arange(obs_group.attrs.get("_n_obs", 0))

        if "column-order" in obs_group.attrs:
            col_order = list(_decode(obs_group.attrs["column-order"]))
        elif "__categories" in obs_group.attrs:
            col_order = [k for k in obs_group.keys() if k not in ("_index", "index", "__categories")]
        else:
            col_order = list(obs_group.attrs.get("column-order", []))

        index_exclude = {index_col_name, "_index"}
        col_order = [c for c in col_order if c not in index_exclude]

        data = {}
        for col in col_order:
            if col not in obs_group:
                continue
            ds = obs_group[col]
            encoding_type = ds.attrs.get("encoding-type", "")
            if encoding_type == "categorical":
                codes = ds["codes"][()]
                categories = _decode(ds["categories"][()])
                ordered = ds.attrs.get("ordered", False)
                values = pd.Categorical.from_codes(codes, categories=categories, ordered=ordered)
                data[col] = values
            elif encoding_type == "nullable-integer":
                data[col] = pd.array(ds[()], dtype=pd.Int64Dtype())
            else:
                arr = ds[()]
                if arr.dtype.kind in ("S", "U", "O"):
                    arr = _decode(arr)
                data[col] = arr

        obs = pd.DataFrame(data, index=index)
        obs.index.name = obs_group.attrs.get("_index", None)

    return obs


def write_obs_to_h5ad(h5ad_path, obs):
    """Write obs dataframe back to h5ad, replacing existing obs group."""
    with h5py.File(h5ad_path, "a") as f:
        old_attrs = dict(f["obs"].attrs)
        del f["obs"]
        obs_group = f.create_group("obs")

        index_col_name = old_attrs.get("_index", "_index")
        if isinstance(index_col_name, bytes):
            index_col_name = index_col_name.decode()
        index_data = np.array(obs.index, dtype=h5py.string_dtype())
        obs_group.create_dataset(index_col_name, data=index_data)

        col_order = np.array(list(obs.columns), dtype=h5py.string_dtype())
        obs_group.attrs["column-order"] = col_order
        obs_group.attrs["_index"] = index_col_name
        obs_group.attrs["encoding-type"] = "dataframe"
        obs_group.attrs["encoding-version"] = old_attrs.get("encoding-version", "0.2.0")

        for col in obs.columns:
            series = obs[col]
            if isinstance(series.dtype, pd.CategoricalDtype):
                grp = obs_group.create_group(col)
                cats = np.array(series.cat.categories, dtype=h5py.string_dtype())
                codes = series.cat.codes.values
                grp.create_dataset("categories", data=cats)
                grp.create_dataset("codes", data=codes)
                grp.attrs["encoding-type"] = "categorical"
                grp.attrs["encoding-version"] = "0.2.0"
                grp.attrs["ordered"] = series.cat.ordered
            elif isinstance(series.dtype, (pd.Float64Dtype, pd.Int64Dtype)):
                vals = series.to_numpy(dtype="float64", na_value=np.nan)
                obs_group.create_dataset(col, data=vals)
            elif series.dtype == bool or series.dtype == np.bool_:
                obs_group.create_dataset(col, data=series.values)
                obs_group[col].attrs["encoding-type"] = "array"
                obs_group[col].attrs["encoding-version"] = "0.2.0"
            elif series.dtype == object or series.dtype.kind in ("U", "S"):
                str_data = np.array(series.fillna(""), dtype=h5py.string_dtype())
                obs_group.create_dataset(col, data=str_data)
            else:
                obs_group.create_dataset(col, data=series.values)


# ---------------------------------------------------------------------------
# HCA validation fixes
# ---------------------------------------------------------------------------
# Columns HCA does not collect -> removed entirely
DROP_COLUMNS = ["self_reported_ethnicity_ontology_term_id"]

# Columns HCA requires to be a single identifier per cell -> single value or NaN
SINGLE_VALUE_COLUMNS = ["library_preparation_batch", "library_sequencing_run"]

# Values treated as missing (case-insensitive)
PLACEHOLDERS = {"unknown", "", "nan", "none", "na"}


def to_single_or_nan(series):
    """Keep single identifiers; set comma-joined aggregates and placeholders to NaN."""
    def clean(v):
        if v is None:
            return np.nan
        s = str(v).strip()
        if s.lower() in PLACEHOLDERS:
            return np.nan
        if "," in s:  # donor-level comma-joined aggregate, not a single value
            return np.nan
        return s
    return series.map(clean)


def patch(h5ad_path):
    print(f"Patching HCA validation fields in: {h5ad_path}")
    obs = read_obs_from_h5ad(h5ad_path)
    print(f"  obs shape: {obs.shape}")

    for col in DROP_COLUMNS:
        if col in obs.columns:
            obs = obs.drop(columns=[col])
            print(f"  dropped column: {col}")
        else:
            print(f"  (not present, skipped): {col}")

    for col in SINGLE_VALUE_COLUMNS:
        if col not in obs.columns:
            print(f"  (not present, skipped): {col}")
            continue
        cleaned = to_single_or_nan(obs[col].astype("object"))
        n_total = len(cleaned)
        n_missing = int(cleaned.isna().sum())
        # categorical so NaN encodes as a proper missing value (code -1), not ""
        obs[col] = pd.Categorical(cleaned)
        n_cats = len(obs[col].cat.categories)
        print(f"  {col}: {n_total - n_missing}/{n_total} single values kept, "
              f"{n_missing} set to NaN, {n_cats} distinct values")

    print(f"  writing obs back ({len(obs.columns)} columns)...")
    write_obs_to_h5ad(h5ad_path, obs)
    print("  done.")


def main():
    p = argparse.ArgumentParser(
        description="Fix HCA validation errors in obs (h5py, no full load)"
    )
    p.add_argument("--h5ad", required=True, help="Path to h5ad file (modified in place)")
    args = p.parse_args()
    patch(args.h5ad)


if __name__ == "__main__":
    main()
