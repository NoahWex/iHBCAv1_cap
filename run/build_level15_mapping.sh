#!/bin/bash
#SBATCH --job-name=l15_mapping
#SBATCH --partition=standard
#SBATCH --account=your_lab_account
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --output=/path/to/iHBCAv1_upload/logs/l15_mapping_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/l15_mapping_%j.err

# =============================================================================
# Build level1.5_annotation -> CL term mapping table
# =============================================================================
# Reads integrated h5ad (backed mode), extracts label -> CL distributions
# Output: mappings/level15_to_cl_mapping_raw.csv
# =============================================================================

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
PY_CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

echo "=== Level1.5 -> CL Mapping Builder ==="
echo "Date: $(date)"
echo "Node: $(hostname)"
echo "Job ID: ${SLURM_JOB_ID}"
echo ""

# Verify key inputs exist
INTEGRATED="${REPO_ROOT}/outputs/integrated_objects/all-breast-cells.h5ad"
if [ ! -f "$INTEGRATED" ]; then
    echo "ERROR: Integrated h5ad not found: $INTEGRATED"
    exit 1
fi
echo "Input: $INTEGRATED ($(ls -lh "$INTEGRATED" | awk '{print $5}'))"

# Create output directories
mkdir -p "${REPO_ROOT}/mappings"
mkdir -p "${REPO_ROOT}/logs"

# Load singularity
module load singularity

echo ""
echo "Starting mapping build..."
singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    --env "MPLCONFIGDIR=/tmp/matplotlib_config" \
    "$PY_CONTAINER" \
    python3 "${REPO_ROOT}/scripts/build_level15_mapping.py" \
        --repo-root "$REPO_ROOT"

echo ""
echo "=== Mapping Build Complete ==="
echo "Exit code: $?"
