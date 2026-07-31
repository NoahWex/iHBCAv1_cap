#!/bin/bash
#SBATCH --job-name=enrich_integrated
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --cpus-per-task=8
#SBATCH --mem=256G
#SBATCH --time=06:00:00
#SBATCH --output=/path/to/iHBCAv1_upload/logs/enrich_integrated_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/enrich_integrated_%j.err

# =============================================================================
# Enrich integrated h5ad: all-breast-cells
# =============================================================================
# Enriches all-breast-cells.h5ad with var, obs, uns, and log_normalized layer.
#
# 256GB for all-breast-cells (2.1M cells + log_normalized layer).
# =============================================================================

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="${REPO_ROOT}/scripts"
# Env-var override for alternate builds (e.g., INTEGRATED_DIR=.../cxg_build/integrated_objects)
OUTDIR="${INTEGRATED_DIR:-${REPO_ROOT}/outputs/integrated_objects}"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

echo "============================================="
echo "Enrich integrated h5ads"
echo "  Date: $(date)"
echo "  Node: $(hostname)"
echo "  Job ID: ${SLURM_JOB_ID}"
echo "  Memory: ${SLURM_MEM_PER_NODE}MB"
echo "============================================="

run_enrich() {
    local H5AD="$1"
    local SKIP_LAYERS="${2:-}"
    local FILENAME
    FILENAME=$(basename "$H5AD")

    echo ""
    echo "--- Processing: ${FILENAME} ---"
    if [ ! -f "${H5AD}" ]; then
        echo "ERROR: h5ad not found: ${H5AD}"
        return 1
    fi
    echo "Input size: $(ls -lh "${H5AD}" | awk '{print $5}')"

    singularity exec \
        --no-mount bind-paths \
        --bind /path/to/shared_data:/path/to/shared_data:ro \
        --bind /path/to/workspace:/path/to/workspace:rw \
        --bind /dfs7:/dfs7:ro \
        --bind /dfs8:/dfs8:ro \
        --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
        --env "MPLCONFIGDIR=/tmp/matplotlib_config" \
        "$CONTAINER" \
        python3 "${SCRIPTS}/enrich_h5ads.py" \
            --h5ad "$H5AD" \
            --mode integrated \
            --repo-root "$REPO_ROOT" \
            ${SKIP_LAYERS}

    echo "Output size: $(ls -lh "${H5AD}" | awk '{print $5}')"
    echo "DONE: ${FILENAME}"
}

module load singularity

run_enrich "${OUTDIR}/all-breast-cells.h5ad"

echo ""
echo "============================================="
echo "Integrated enrichment COMPLETE"
echo "Date: $(date)"
echo "============================================="
