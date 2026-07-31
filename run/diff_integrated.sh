#!/bin/bash
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --cpus-per-task=4
#SBATCH --mem=256G
#SBATCH --time=02:00:00
#SBATCH --job-name=diff_integrated
#SBATCH --output=/path/to/iHBCAv1_upload/logs/diff_integrated_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/diff_integrated_%j.err

# Diff integrated object vs CxG published h5ad (OOM'd at 180GB, retrying at 256GB)

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="$REPO_ROOT/scripts"
REPORT_DIR="$REPO_ROOT/outputs/validation_reports"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

NEW="$REPO_ROOT/outputs/integrated_objects/all-breast-cells.h5ad"
REF="/path/to/shared_data/3_Downloaded_Datasets/iHBCA_Reed_2024/integrated_atlas/integration_iHBCA.h5ad"

echo "DIFF: integrated (all-breast-cells vs CxG published)"
echo "  New: $(ls -lh "$NEW" | awk '{print $5}')"
echo "  Ref: $(ls -lh "$REF" | awk '{print $5}')"
echo "  Memory: ${SLURM_MEM_PER_NODE}MB"
echo "  Date: $(date)"

module load singularity

singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    --env "MPLCONFIGDIR=/tmp/matplotlib_config" \
    "$CONTAINER" \
    python3 "$SCRIPTS/diff_h5ads.py" \
        --new "$NEW" \
        --reference "$REF" \
        --output "$REPORT_DIR/integrated_regen_diff.yaml"

echo ""
echo "Done: $(date)"
