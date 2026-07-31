#!/bin/bash
#SBATCH --job-name=patch_var_uns
#SBATCH --account=your_lab_account
#SBATCH --partition=free
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:20:00
#SBATCH --output=/path/to/iHBCAv1_upload/logs/patch_var_uns_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/patch_var_uns_%j.err

# Fix CxG 5.3.2 validation blockers on 8 h5ads (7 source + all-breast-cells)
# - Delete uns["layer_descriptions"] (deprecated)
# - Rename var["feature_biotype"] -> var["feature_biotype_gencode"] (reserved)
# Lineage splits excluded — will be regenerated from parent.

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="${REPO_ROOT}/scripts"
SOURCE_DIR="${REPO_ROOT}/outputs/source_datasets"
INTEGRATED_DIR="${REPO_ROOT}/outputs/integrated_objects"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

echo "============================================="
echo "Patch var/uns: CxG 5.3.2 fixes"
echo "  Date: $(date)"
echo "  Node: $(hostname)"
echo "  Job ID: ${SLURM_JOB_ID}"
echo "============================================="

module load singularity

FILES=(
    "${SOURCE_DIR}/gray2022.h5ad"
    "${SOURCE_DIR}/kumar2023.h5ad"
    "${SOURCE_DIR}/murrow2022.h5ad"
    "${SOURCE_DIR}/nee2023.h5ad"
    "${SOURCE_DIR}/twigger2022.h5ad"
    "${SOURCE_DIR}/reed2024.h5ad"
    "${SOURCE_DIR}/pal2021.h5ad"
    "${INTEGRATED_DIR}/all-breast-cells.h5ad"
)

singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    "$CONTAINER" \
    python3 "${SCRIPTS}/patch_var_uns_h5py.py" \
        --h5ad "${FILES[@]}"

echo ""
echo "============================================="
echo "All patches COMPLETE"
echo "Date: $(date)"
echo "============================================="
