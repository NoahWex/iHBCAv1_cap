#!/bin/bash
#SBATCH --job-name=patch_obs_fields
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --time=00:30:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=1
#SBATCH --output=/path/to/iHBCAv1_upload/logs/patch_obs_fields_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/patch_obs_fields_%j.err

# Patch obs columns in integrated + sketch h5ads:
#   1. facs_status: use FACS_status for murrow/pal/reed (sample-level source is correct)
#   2. n_genes, n_counts, percent_mito: categorical-of-strings → float32

set -euo pipefail

PROJECT=/path/to/iHBCAv1_upload
SCRIPT=$PROJECT/scripts/patch_obs_fields.py
INTEGRATED=$PROJECT/outputs/integrated_objects/all-breast-cells.h5ad
SKETCH=$PROJECT/outputs/integrated_objects/all-breast-cells-sketch.h5ad

CONTAINER=/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif
BINDS="--bind /path/to/workspace:/path/to/workspace:rw \
       --bind /dfs8:/dfs8:ro"

module load singularity

echo "=== Patch obs fields: facs_status + numeric dtypes ==="
echo "Date: $(date)"
echo "Job: $SLURM_JOB_ID"

singularity exec $BINDS \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    "$CONTAINER" \
    python3 "$SCRIPT" "$INTEGRATED" "$SKETCH"

echo ""
echo "=== Done ==="
echo "Date: $(date)"
