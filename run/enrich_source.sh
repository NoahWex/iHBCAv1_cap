#!/bin/bash
#SBATCH --job-name=enrich_source
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --array=0-6
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=02:00:00
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/enrich_source_%A_%a.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/enrich_source_%A_%a.err

# =============================================================================
# Enrich source h5ads with var annotations, uns documentation, obs polish
# =============================================================================
# Array index -> study mapping:
#   0=gray  1=kumar  2=murrow  3=nee  4=twigger  5=reed  6=pal
#
# 128GB for all tasks (reed is 803K cells, needs headroom)
# =============================================================================

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="${REPO_ROOT}/publication/scripts"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

STUDIES=(gray kumar murrow nee twigger reed pal)
FILENAMES=(gray2022.h5ad kumar2023.h5ad murrow2022.h5ad nee2023.h5ad twigger2022.h5ad reed2024.h5ad pal2021.h5ad)

INDEX="${SLURM_ARRAY_TASK_ID:?Must run as SLURM array job}"
STUDY="${STUDIES[$INDEX]}"
FILENAME="${FILENAMES[$INDEX]}"

# Env-var override for alternate builds (e.g., SOURCE_DIR=.../cxg_build/source_datasets)
SOURCE_DIR="${SOURCE_DIR:-${REPO_ROOT}/publication/outputs/source_datasets}"
H5AD="${SOURCE_DIR}/${FILENAME}"

echo "============================================="
echo "Enrich source h5ad: ${STUDY}"
echo "  File: ${FILENAME}"
echo "  Array index: ${INDEX}"
echo "  Date: $(date)"
echo "  Node: $(hostname)"
echo "  Job ID: ${SLURM_JOB_ID}"
echo "  Memory: ${SLURM_MEM_PER_NODE}MB"
echo "============================================="

if [ ! -f "${H5AD}" ]; then
    echo "ERROR: h5ad not found: ${H5AD}"
    exit 1
fi

echo "Input size: $(ls -lh "${H5AD}" | awk '{print $5}')"

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
    python3 "${SCRIPTS}/enrich_h5ads.py" \
        --h5ad "$H5AD" \
        --mode source \
        --study "$STUDY" \
        --repo-root "$REPO_ROOT" \
        --skip-layers

echo ""
echo "Enrichment COMPLETE: ${STUDY}"
echo "Output size: $(ls -lh "${H5AD}" | awk '{print $5}')"
