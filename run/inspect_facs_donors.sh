#!/bin/bash
#SBATCH --job-name=inspect_facs_d
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --time=00:15:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --output=/path/to/iHBCAv1_upload/logs/inspect_facs_donors_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/inspect_facs_donors_%j.err

set -euo pipefail

SIF=/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif
H5AD=/path/to/iHBCAv1_upload/outputs/integrated_objects/all-breast-cells.h5ad
L1_CSV=/path/to/iHBCAv1_upload/config/metadata_stages/L1_harmonized_donor.csv

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

l1 = pd.read_csv('$L1_CSV', dtype=str)
print(f'L1 CSV shape: {l1.shape}')
print(f'L1 columns: {list(l1.columns)}')
print()

# For each disagreeing dataset, show per-donor breakdown
for ds in ['murrow', 'pal', 'reed']:
    sub = obs[obs['dataset'] == ds][['donor_id', 'facs_status', 'FACS_status']].copy()
    sub['agree'] = sub['facs_status'].astype(str) == sub['FACS_status'].astype(str)
    disagree_donors = sub[~sub['agree']]['donor_id'].unique()

    print(f'=== {ds}: {len(disagree_donors)} donors with disagreements ===')

    # Per-donor summary from obs
    donor_summary = sub.groupby('donor_id').apply(
        lambda g: pd.Series({
            'n_cells': len(g),
            'facs_status_vals': ','.join(sorted(g['facs_status'].astype(str).unique())),
            'FACS_status_vals': ','.join(sorted(g['FACS_status'].astype(str).unique())),
            'agrees': g['agree'].all()
        })
    ).reset_index()

    disagree_summary = donor_summary[~donor_summary['agrees']]
    print(f'  Disagreeing donors ({len(disagree_summary)}):')
    print(disagree_summary.to_string(index=False))
    print()

    # Cross-check against L1 CSV
    l1_ds = l1[l1['dataset'] == ds][['donor_id', 'facs_status']] if 'dataset' in l1.columns else pd.DataFrame()
    if not l1_ds.empty:
        merged = disagree_summary.merge(l1_ds, on='donor_id', how='left', suffixes=('_obs', '_l1'))
        print(f'  L1 CSV facs_status for disagreeing donors:')
        print(merged[['donor_id', 'facs_status_vals', 'FACS_status_vals', 'facs_status']].to_string(index=False))
    print()
"
