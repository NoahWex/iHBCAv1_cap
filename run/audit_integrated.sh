#!/bin/bash
#SBATCH --job-name=audit_integrated
#SBATCH --partition=standard
#SBATCH --account=your_lab_account
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=256G
#SBATCH --time=04:00:00
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/audit_integrated_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/audit_integrated_%j.err

# =============================================================================
# Structural audit of the iHBCA integrated h5ad object
# =============================================================================
# Produces a YAML report with full column-level detail for obs, var, obsm,
# uns, layers, and raw. Output: integrated_object_audit_raw.yaml
# =============================================================================

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
PUB_ROOT="${REPO_ROOT}/publication"
PY_CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

INPUT="${PUB_ROOT}/outputs/integrated_objects/all-breast-cells.h5ad"
OUTPUT="${PUB_ROOT}/outputs/integrated_object_audit_raw.yaml"

echo "=== Integrated Object Audit ==="
echo "Date: $(date)"
echo "Node: $(hostname)"
echo "Job ID: ${SLURM_JOB_ID}"
echo "Memory: ${SLURM_MEM_PER_NODE}MB"
echo ""

# Verify input exists
if [ ! -f "$INPUT" ]; then
    echo "ERROR: Input not found: $INPUT"
    exit 1
fi
echo "Input: $INPUT ($(ls -lh "$INPUT" | awk '{print $5}'))"
echo "Output: $OUTPUT"
echo ""

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT")"

# Load singularity
module load singularity

echo "Starting audit..."
singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    --env "MPLCONFIGDIR=/tmp/matplotlib_config" \
    "$PY_CONTAINER" \
    python3 "${PUB_ROOT}/scripts/audit_integrated.py" \
        "$INPUT" \
        --output "$OUTPUT"

echo ""
echo "=== Audit Complete ==="
echo "Output: $OUTPUT ($(ls -lh "$OUTPUT" | awk '{print $5}'))"
echo "Exit code: $?"
