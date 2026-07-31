#!/usr/bin/env bash
# =============================================================================
# Download SRA metadata and build standardized run tables
# =============================================================================
# Two-step pipeline:
#   Step 1: Download raw ENA/SDRF metadata (needs internet → login node)
#   Step 2: Parse into per-study CSVs (needs pandas → container)
#
# Usage:
#   # Run both steps on login node (or interactive session with internet):
#   bash run/build_sra_run_tables.sh
#
#   # Or as SLURM job (Step 2 only, after manual download):
#   sbatch run/build_sra_run_tables.sh
#
# =============================================================================
#SBATCH --job-name=build_sra_tables
#SBATCH --partition=standard
#SBATCH --account=your_lab_account
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=/path/to/iHBCAv1_upload/logs/build_sra_tables_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/build_sra_tables_%j.err

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
RAW_DIR="$REPO_ROOT/mappings/sra_raw"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

# Step 1: Download (skip if raw files already exist)
if [ ! -d "$RAW_DIR" ] || [ -z "$(ls -A "$RAW_DIR" 2>/dev/null)" ]; then
    echo "=== Step 1: Downloading raw SRA/SDRF metadata ==="
    bash "$REPO_ROOT/run/download_sra_metadata.sh" "$REPO_ROOT"
else
    echo "=== Step 1: Raw files already exist in $RAW_DIR, skipping download ==="
    ls -lh "$RAW_DIR/"
fi

echo ""
echo "=== Step 2: Parsing into standardized run tables ==="

module load singularity 2>/dev/null || true

singularity exec \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    --env "MPLCONFIGDIR=/tmp/matplotlib_config" \
    "$CONTAINER" \
    python "$REPO_ROOT/scripts/build_sra_run_tables.py" \
        --repo-root "$REPO_ROOT"

echo ""
echo "=== Complete ==="
