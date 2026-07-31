#!/bin/bash
#SBATCH --job-name=diff_baseline
#SBATCH --partition=standard
#SBATCH --account=your_lab_account
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=180G
#SBATCH --time=02:00:00
#SBATCH --output=/path/to/iHBCAv1_upload/logs/diff_baseline_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/diff_baseline_%j.err

# =============================================================================
# Diff current h5ads against baseline manifest (structural comparison)
# =============================================================================
# Plan: Activation/pipeline_rebuild (Phase 1 gate)
# Compares cell counts, gene counts, obs columns/dtypes, obsm keys, uns keys
# against the Phase 0 baseline manifest.
# =============================================================================

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
PUB_ROOT="${REPO_ROOT}/publication"
PY_CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"
MANIFEST="${PUB_ROOT}/outputs/baseline_manifest.yaml"

echo "=== Diff Against Baseline ==="
echo "Date: $(date)"
echo "Job ID: ${SLURM_JOB_ID}"
echo ""

module load singularity

# Diff integrated objects only (source datasets were not rebuilt)
singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    "$PY_CONTAINER" \
    python3 "${PUB_ROOT}/scripts/diff_against_baseline.py" \
        --manifest "$MANIFEST" \
        --repo-root "$REPO_ROOT" \
        --datasets all-breast-cells breast-epithelial-lineage breast-stromal-lineage breast-immune-lineage

echo ""
echo "Exit code: $?"
