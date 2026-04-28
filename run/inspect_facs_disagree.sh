#!/bin/bash
#SBATCH --job-name=inspect_facs
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --time=00:15:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/inspect_facs_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/inspect_facs_%j.err

set -euo pipefail

SIF=/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif
H5AD=/path/to/iHBCAv1_upload/publication/outputs/integrated_objects/all-breast-cells.h5ad

module load singularity

singularity exec \
    --bind /path/to/workspace:/path/to/workspace \
    --bind /dfs8:/dfs8 \
    "$SIF" python3 -c "
import anndata as ad
import pandas as pd

print('Loading...')
adata = ad.read_h5ad('$H5AD', backed='r')
obs = adata.obs

disagree = obs[obs['facs_status'].astype(str) != obs['FACS_status'].astype(str)][
    ['dataset', 'facs_status', 'FACS_status']
]

print(f'Total disagreements: {len(disagree):,} / {len(obs):,} cells')
print()

print('=== By dataset ===')
print(disagree.groupby('dataset').size().sort_values(ascending=False).to_string())
print()

print('=== Disagreement patterns by dataset ===')
for ds, grp in disagree.groupby('dataset'):
    print(f'--- {ds} ({len(grp):,} cells) ---')
    ct = pd.crosstab(grp['facs_status'].astype(str), grp['FACS_status'].astype(str))
    print(ct.to_string())
    print()
"
