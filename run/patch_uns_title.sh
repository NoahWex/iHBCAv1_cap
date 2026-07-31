#!/bin/bash
#SBATCH --job-name=patch_uns_title
#SBATCH --account=your_lab_account
#SBATCH --partition=free
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=/path/to/iHBCAv1_upload/logs/patch_uns_title_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/patch_uns_title_%j.err

# Set uns["title"] (see TITLE below) in both integrated objects in
# upload-staging. This is the authoritative title; assemble_integrated.py only
# sets a placeholder when none is present.

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="${REPO_ROOT}/scripts"
STAGING="${REPO_ROOT}/upload-staging/integrated-objects"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

TITLE="iHBCA v1"

echo "============================================="
echo "Patch uns[title] — integrated objects"
echo "  Date:    $(date)"
echo "  Node:    $(hostname)"
echo "  Job ID:  ${SLURM_JOB_ID}"
echo "  Title:   ${TITLE}"
echo "============================================="

module load singularity

singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs8:/dfs8:ro \
    "$CONTAINER" \
    python3 "${SCRIPTS}/patch_uns_title.py" \
        --h5ad \
            "${STAGING}/all-breast-cells.h5ad" \
            "${STAGING}/all-breast-cells-sketch.h5ad" \
        --title "${TITLE}"

echo ""
echo "============================================="
echo "Patch COMPLETE: $(date)"
echo "Next: re-upload integrated-objects to S3"
echo "============================================="
