#!/bin/bash
#SBATCH --job-name=gtf_gene_map
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --time=00:30:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --output=/path/to/iHBCAv1_upload/logs/gtf_gene_map_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/logs/gtf_gene_map_%j.err

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="${REPO_ROOT}/scripts"
MAPPINGS="${REPO_ROOT}/mappings"
INTERMEDIATES="${REPO_ROOT}/outputs/source_datasets/intermediates"
GTF="/path/to/shared_data/spaceranger-data/refdata-gex-GRCh38-2020-A/genes/genes.gtf"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

echo "============================================="
echo "Build comprehensive GTF-based gene mapping"
echo "============================================="

module load singularity

singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    --env "NUMBA_CACHE_DIR=/tmp/numba_cache" \
    "$CONTAINER" \
    python "${SCRIPTS}/build_gtf_gene_mapping.py" \
        --gtf "${GTF}" \
        --output "${MAPPINGS}/gene_symbol_to_ensembl_full.tsv" \
        --existing-mapping "${MAPPINGS}/gene_symbol_to_ensembl.tsv" \
        --hgnc "${MAPPINGS}/hgnc_complete_set.txt" \
        --test-features \
            "${INTERMEDIATES}/murrow/features.tsv.gz" \
            "${INTERMEDIATES}/nee/features.tsv.gz" \
            "${INTERMEDIATES}/pal_norm_epi/features.tsv.gz" \
            "${INTERMEDIATES}/gray/features.tsv.gz" \
            "${INTERMEDIATES}/kumar/features.tsv.gz" \
            "${INTERMEDIATES}/twigger/features.tsv.gz" \
            "${INTERMEDIATES}/reed/features.tsv.gz"

echo ""
echo "COMPLETE"
