#!/bin/bash
#SBATCH --job-name=plot_umaps
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --array=0-5
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --time=00:30:00
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/plot_umaps_%a_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/plot_umaps_%a_%j.err

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="${REPO_ROOT}/publication/scripts"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

STUDIES=(gray kumar murrow nee twigger reed)
INDEX="${SLURM_ARRAY_TASK_ID:?Must run as SLURM array job}"
STUDY="${STUDIES[$INDEX]}"

echo "Plotting enriched UMAP: ${STUDY}"

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
    python3 "${SCRIPTS}/plot_enriched_umaps.py" \
        --study "$STUDY" \
        --repo-root "$REPO_ROOT"

echo "Plot COMPLETE: ${STUDY}"
