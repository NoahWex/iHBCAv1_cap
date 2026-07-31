#!/bin/bash
#SBATCH --job-name=patch_fif_raw
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=/path/to/iHBCAv1_upload/logs/patch_fif_raw_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/patch_fif_raw_%j.err

# Remove feature_is_filtered from raw/var in restructured h5ads.
# HCA schema prohibits this column in raw.var.

set -euo pipefail

PROJECT="/path/to/iHBCAv1_upload"
SCRIPT="$PROJECT/scripts/patch_remove_feature_is_filtered_raw.py"
INTEGRATED="$PROJECT/outputs/integrated_objects/all-breast-cells.h5ad"
SKETCH="$PROJECT/outputs/integrated_objects/all-breast-cells-sketch.h5ad"

CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"
BINDS="--bind /path/to/shared_data:/path/to/shared_data:ro \
       --bind /path/to/workspace:/path/to/workspace:rw \
       --bind /dfs7:/dfs7:ro \
       --bind /dfs8:/dfs8:ro"

module load singularity

echo "=== Patch: remove feature_is_filtered from raw/var ==="
echo "Date: $(date)"
echo "Job: $SLURM_JOB_ID"
echo ""

singularity exec $BINDS \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    "$CONTAINER" \
    python3 "$SCRIPT" "$INTEGRATED" "$SKETCH"

echo ""
echo "=== Done ==="
echo "Date: $(date)"
