"""Shared data loaders for iHBCA assembly pipeline.

All mapping/config file loading functions used by both assemble_h5ad.py
(source datasets) and assemble_integrated.py (integrated object).
"""

import pandas as pd
import yaml


# ---------------------------------------------------------------------------
# Mapping file loaders
# ---------------------------------------------------------------------------


def load_hancestro_mapping(repo_root):
    """Load HANCESTRO ethnicity mapping (ethnicity_verbatim -> term_id)."""
    path = repo_root / "publication/mappings/hancestro_ethnicity_mapping.tsv"
    df = pd.read_csv(path, sep="\t", comment="#")
    return dict(zip(df["ethnicity_verbatim"], df["hancestro_term_id"]))


def load_gene_mapping(repo_root):
    """Load gene symbol -> Ensembl ID mapping table.

    Prefers the comprehensive GTF+HGNC mapping (_full.tsv) if it exists,
    falls back to the original Cell Ranger h5-derived mapping.
    """
    full_path = repo_root / "publication/mappings/gene_symbol_to_ensembl_full.tsv"
    base_path = repo_root / "publication/mappings/gene_symbol_to_ensembl.tsv"
    path = full_path if full_path.exists() else base_path
    df = pd.read_csv(path, sep="\t", comment="#")
    return dict(zip(df["gene_symbol"], df["ensembl_id"]))


def load_efo_assay_mapping(repo_root):
    """Load EFO assay mapping (study -> efo_term_id)."""
    path = repo_root / "publication/mappings/efo_assay_mapping.tsv"
    df = pd.read_csv(path, sep="\t", comment="#")
    return dict(zip(df["study"], df["efo_term_id"]))


def load_cl_crosswalk(repo_root, study):
    """Load pre-computed CL term crosswalk for non-CxG studies.

    Returns dict: source_cell_id -> cell_type_ontology_term_id.
    Returns empty dict if crosswalk file not found (graceful degradation).
    """
    path = repo_root / f"publication/mappings/cl_term_crosswalk_{study}.csv"
    if not path.exists():
        return {}
    df = pd.read_csv(path)
    return dict(zip(df["source_cell_id"], df["cell_type_ontology_term_id"]))


def load_cxg_approved_genes(repo_root):
    """Load CxG approved gene set (GENCODE v44 / Ensembl 110).

    Returns set of approved Ensembl IDs, or None if file not found.
    """
    path = repo_root / "publication/mappings/cxg_approved_genes.txt"
    if path.exists():
        return set(path.read_text().strip().split("\n"))
    print(f"  WARNING: CxG approved gene list not found: {path}")
    return None


def load_gencode_annotations(repo_root):
    """Load cached GENCODE v24 gene annotations.

    Returns DataFrame indexed by ensembl_id with gene_symbol, feature_biotype,
    chromosome columns, or None if file not found.
    """
    path = repo_root / "publication/mappings/gencode_v24_gene_annotations.tsv"
    if not path.exists():
        print(f"  WARNING: GENCODE annotations not found: {path}")
        return None
    return pd.read_csv(path, sep="\t", index_col="ensembl_id")


# ---------------------------------------------------------------------------
# Config file loaders
# ---------------------------------------------------------------------------


def load_registry(repo_root):
    """Load source dataset registry YAML."""
    path = repo_root / "publication/config/source_dataset_registry.yaml"
    with open(path) as f:
        return yaml.safe_load(f)


def load_dataset_metadata(repo_root):
    """Load per-study dataset metadata from YAML.

    Returns the full parsed YAML dict, or empty dict if not found.
    """
    path = repo_root / "publication/config/dataset_metadata.yaml"
    if not path.exists():
        print(f"  WARNING: {path} not found")
        return {}
    with open(path) as f:
        return yaml.safe_load(f)


# ---------------------------------------------------------------------------
# Donor metadata loaders
# ---------------------------------------------------------------------------


def load_l1_metadata(repo_root):
    """Load L1 harmonized donor metadata staging CSV.

    Returns DataFrame or None if file not found (graceful degradation).
    """
    path = repo_root / "publication/config/metadata_stages/L1_harmonized_donor.csv"
    if not path.exists():
        print(f"  WARNING: L1 metadata not found: {path}")
        return None
    return pd.read_csv(path, dtype=str)


def load_donor_translations(repo_root):
    """Load donor ID translation CSVs for studies with ID mismatches.

    Reed and Pal use different donor ID schemes in L1 harmonized metadata
    vs the CxG h5ad. Translation CSVs bridge:
      Reed: tissue bank ID (2973CP) -> HBCA_Donor_54
      Pal:  group-derived ID (N_0064) -> Pal_MH0064

    Returns dict mapping L1 constructed key ({Study}_{ihbca_donor_id})
    to the actual h5ad donor_id (cxg_donor_id).
    """
    translations = {}
    for study in ("reed", "pal"):
        path = repo_root / f"publication/mappings/donor_id_translation_{study}.csv"
        if not path.exists():
            continue
        df = pd.read_csv(path, dtype=str)
        for _, row in df.iterrows():
            l1_key = f"{row['study'].capitalize()}_{row['ihbca_donor_id'].strip()}"
            translations[l1_key] = row["cxg_donor_id"].strip()
    return translations
