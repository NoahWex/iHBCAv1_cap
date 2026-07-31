#!/usr/bin/env python3
"""
Render clean original per-study UMAPs for Fig 1A assembly schematic.

Reads X_umap (original study coordinates) from each source h5ad,
colors by cell_type_label, renders minimal scatter plots suitable
for small thumbnail embedding (~10mm at print).

No titles, no axes, no legends — just the scatter. The schematic
script adds labels externally.
"""

import argparse
from pathlib import Path
import anndata as ad
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

STUDY_FILES = {
    "gray": "gray2022.h5ad",
    "kumar": "kumar2023.h5ad",
    "murrow": "murrow2022.h5ad",
    "nee": "nee2023.h5ad",
    "pal": "pal2021.h5ad",
    "reed": "reed2024.h5ad",
    "twigger": "twigger2022.h5ad",
}

# Preferred cell type column in priority order
CELL_TYPE_COLS = [
    "cell_type_label", "cell_type", "cellSubtype",
    "author_cell_type", "original_celltype", "level2",
]


def find_cell_type_col(obs_columns):
    """Return the first available cell-type annotation column in obs."""
    for col in CELL_TYPE_COLS:
        if col in obs_columns:
            return col
    return None


def render_study_umap(adata, study, output_dir):
    """Render a clean UMAP scatter for one study."""
    if "X_umap" not in adata.obsm:
        print(f"  WARNING: {study} has no X_umap, skipping")
        return

    coords = np.array(adata.obsm["X_umap"])
    valid = ~np.isnan(coords).any(axis=1)
    coords = coords[valid]

    # Color by cell type
    ct_col = find_cell_type_col(adata.obs.columns)
    if ct_col:
        labels = adata.obs[ct_col].values[valid]
        unique = sorted(set(str(l) for l in labels))
        n = len(unique)
        cmap = plt.cm.get_cmap("tab20", max(n, 1)) if n <= 20 else plt.cm.get_cmap("gist_ncar", n)
        color_map = {l: cmap(i) for i, l in enumerate(unique)}
        colors = [color_map[str(l)] for l in labels]
    else:
        colors = "#4477AA"

    # Point size/alpha tuned for thumbnail display (~10mm at print).
    # These need to be much more opaque/visible than full-size UMAPs.
    n_cells = len(coords)
    if n_cells > 500_000:
        s, alpha = 0.3, 0.6
    elif n_cells > 100_000:
        s, alpha = 0.5, 0.7
    elif n_cells > 50_000:
        s, alpha = 1.0, 0.8
    else:
        s, alpha = 2.0, 0.9

    # Render at high resolution for clean downscaling into thumbnails
    fig, ax = plt.subplots(1, 1, figsize=(4, 4), dpi=300)
    ax.scatter(
        coords[:, 0], coords[:, 1],
        c=colors, s=s, alpha=alpha,
        rasterized=True, linewidths=0,
    )
    ax.set_aspect("equal")
    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    # White background
    fig.patch.set_facecolor("white")
    ax.set_facecolor("white")

    out_path = output_dir / f"umap_original_{study}.png"
    fig.savefig(
        str(out_path), dpi=600,
        bbox_inches="tight", pad_inches=0.01,
        facecolor="white",
    )
    plt.close(fig)
    print(f"  Saved: {out_path} ({n_cells:,} cells)")


def main():
    parser = argparse.ArgumentParser(
        description="Render original per-study UMAPs for Fig 1A schematic"
    )
    parser.add_argument("--repo-root", required=True,
                        help="iHBCAv1_upload project root")
    parser.add_argument("--study", help="Single study key (default: all)")
    args = parser.parse_args()

    repo_root = Path(args.repo_root)
    source_dir = repo_root / "outputs/source_datasets"
    output_dir = repo_root / "outputs/figures"
    output_dir.mkdir(parents=True, exist_ok=True)

    studies = [args.study] if args.study else list(STUDY_FILES.keys())

    for study in studies:
        fname = STUDY_FILES.get(study)
        if not fname:
            print(f"Unknown study: {study}")
            continue
        h5ad_path = source_dir / fname
        if not h5ad_path.exists():
            print(f"Skipping {study}: {h5ad_path} not found")
            continue

        print(f"\nRendering {study}...")
        adata = ad.read_h5ad(str(h5ad_path))
        render_study_umap(adata, study, output_dir)
        del adata

    print(f"\nAll plots saved to: {output_dir}")


if __name__ == "__main__":
    main()
