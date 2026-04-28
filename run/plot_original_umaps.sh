#!/bin/bash
#SBATCH --job-name=plot_orig_umaps
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/plot_orig_umaps_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/plot_orig_umaps_%j.err

set -euo pipefail

PROJECT_ROOT="/path/to/iHBCAv1_upload"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"
SCRIPT="$PROJECT_ROOT/publication/scripts/plot_original_umaps.py"

echo "============================================================================"
echo "Plot Original Per-Study UMAPs for Fig 1A Schematic"
echo "============================================================================"
echo "Job ID:       ${SLURM_JOB_ID}"
echo "Node:         ${SLURMD_NODENAME}"
echo "Memory:       ${SLURM_MEM_PER_NODE:-N/A}"
echo "Project Root: $PROJECT_ROOT"
echo "============================================================================"

# Validate
if [ ! -f "$SCRIPT" ]; then
    echo "ERROR: Script not found: $SCRIPT"
    exit 1
fi
if [ ! -f "$CONTAINER" ]; then
    echo "ERROR: Container not found: $CONTAINER"
    exit 1
fi

# Ensure log and output dirs exist
mkdir -p "$PROJECT_ROOT/publication/logs"
mkdir -p "$PROJECT_ROOT/publication/outputs/figures"

module load singularity/3.11.3

START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "Start time: $START_TIME"

singularity exec \
    --pwd "$PROJECT_ROOT" \
    --bind /path/to/lab:/path/to/lab:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    --env "MPLCONFIGDIR=/tmp/matplotlib_config" \
    "$CONTAINER" python3 "$SCRIPT" --repo-root "$PROJECT_ROOT" || {
        EXIT_CODE=$?
        echo "ERROR: Script failed with exit code $EXIT_CODE"
        exit $EXIT_CODE
    }

END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
echo ""
echo "============================================================================"
echo "Complete!"
echo "Start: $START_TIME"
echo "End:   $END_TIME"
echo "============================================================================"

# Verify outputs
echo ""
echo "Output files:"
ls -lh "$PROJECT_ROOT/publication/outputs/figures/umap_original_"*.png 2>/dev/null || echo "  WARNING: No output files found"
