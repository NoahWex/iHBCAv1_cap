#!/bin/bash
#SBATCH --job-name=build_sketch
#SBATCH --account=your_lab_account
#SBATCH --partition=free
#SBATCH --cpus-per-task=8
#SBATCH --mem=256G
#SBATCH --time=04:00:00
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/build_sketch_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/build_sketch_%j.err

# =============================================================================
# Build geometric sketch of integrated iHBCA object
# =============================================================================
# Produces all-breast-cells-sketch.h5ad (~280K cells, 1000/donor via geosketch)
# from the fully enriched all-breast-cells.h5ad (2.1M cells).
#
# 256GB: full h5ad load (~95GB) + subsetting + write overhead.
# =============================================================================

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="${REPO_ROOT}/publication/scripts"
OUTDIR="${REPO_ROOT}/publication/outputs/integrated_objects"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

INPUT="${OUTDIR}/all-breast-cells.h5ad"
OUTPUT="${OUTDIR}/all-breast-cells-sketch.h5ad"

echo "============================================="
echo "Build sketch object"
echo "  Date: $(date)"
echo "  Node: $(hostname)"
echo "  Job ID: ${SLURM_JOB_ID}"
echo "  Memory: ${SLURM_MEM_PER_NODE}MB"
echo "  Input: ${INPUT}"
echo "  Output: ${OUTPUT}"
echo "============================================="

if [ ! -f "${INPUT}" ]; then
    echo "ERROR: Input h5ad not found: ${INPUT}"
    exit 1
fi

echo "Input size: $(ls -lh "${INPUT}" | awk '{print $5}')"

module load singularity

singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    --bind $HOME:$HOME:ro \
    --env "PYTHONPATH=$HOME/.local/lib/python3.10/site-packages" \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    --env "MPLCONFIGDIR=/tmp/matplotlib_config" \
    "$CONTAINER" \
    python3 "${SCRIPTS}/build_sketch.py" \
        --input "$INPUT" \
        --output "$OUTPUT" \
        --cells-per-donor 1000 \
        --seed 42

echo ""
echo "============================================="
echo "Sketch build COMPLETE"
echo "Output size: $(ls -lh "${OUTPUT}" | awk '{print $5}')"
echo "Date: $(date)"
echo "============================================="
