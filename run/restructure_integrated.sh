#!/bin/bash
#SBATCH --job-name=restructure_int
#SBATCH --partition=standard
#SBATCH --account=your_lab_account
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/restructure_integrated_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/restructure_integrated_%j.err

set -euo pipefail

PROJECT="/path/to/iHBCAv1_upload"
SCRIPT="$PROJECT/publication/scripts/restructure_raw_x.py"
INTEGRATED="$PROJECT/publication/outputs/integrated_objects/all-breast-cells.h5ad"
SKETCH="$PROJECT/publication/outputs/integrated_objects/all-breast-cells-sketch.h5ad"
BACKUP_INT="$PROJECT/publication/outputs/integrated_objects/all-breast-cells.h5ad.pre_restructure"
BACKUP_SKT="$PROJECT/publication/outputs/integrated_objects/all-breast-cells-sketch.h5ad.pre_restructure"

CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"
BINDS="--bind /path/to/shared_data:/path/to/shared_data:ro \
       --bind /path/to/workspace:/path/to/workspace:rw \
       --bind /dfs7:/dfs7:ro \
       --bind /dfs8:/dfs8:ro"

module load singularity

echo "=== Restructure h5ads: X ↔ raw.X ==="
echo "Date: $(date)"
echo "Job: $SLURM_JOB_ID"
echo ""

# ---------------------------------------------------------------
# INTEGRATED OBJECT
# ---------------------------------------------------------------
echo "===== INTEGRATED: all-breast-cells.h5ad ====="

# Backup
if [ -f "$BACKUP_INT" ]; then
    echo "Backup already exists — skipping."
else
    echo "Backing up integrated ($(du -h "$INTEGRATED" | cut -f1))..."
    cp "$INTEGRATED" "$BACKUP_INT"
    sleep 3
    echo "Backup complete: $(du -h "$BACKUP_INT" | cut -f1)"
fi
echo ""

# Dry run
echo "Dry run..."
singularity exec $BINDS \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    "$CONTAINER" \
    python3 "$SCRIPT" "$INTEGRATED" --dry-run
echo ""

# Restructure
echo "Restructuring..."
singularity exec $BINDS \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    "$CONTAINER" \
    python3 "$SCRIPT" "$INTEGRATED"

echo ""

# ---------------------------------------------------------------
# SKETCH OBJECT
# ---------------------------------------------------------------
echo "===== SKETCH: all-breast-cells-sketch.h5ad ====="

# Backup
if [ -f "$BACKUP_SKT" ]; then
    echo "Backup already exists — skipping."
else
    echo "Backing up sketch ($(du -h "$SKETCH" | cut -f1))..."
    cp "$SKETCH" "$BACKUP_SKT"
    sleep 3
    echo "Backup complete: $(du -h "$BACKUP_SKT" | cut -f1)"
fi
echo ""

# Dry run
echo "Dry run..."
singularity exec $BINDS \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    "$CONTAINER" \
    python3 "$SCRIPT" "$SKETCH" --dry-run
echo ""

# Restructure
echo "Restructuring..."
singularity exec $BINDS \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    "$CONTAINER" \
    python3 "$SCRIPT" "$SKETCH"

echo ""
echo "=== Done ==="
echo "Backups:"
echo "  $BACKUP_INT"
echo "  $BACKUP_SKT"
echo "Next: re-validate both with CAP + HCA validators"
