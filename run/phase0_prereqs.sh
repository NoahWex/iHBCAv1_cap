#!/bin/bash
#SBATCH --job-name=enrich_prereqs
#SBATCH --account=your_lab_account
#SBATCH --partition=standard
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=/path/to/iHBCAv1_upload/publication/logs/enrich_prereqs_%j.out
#SBATCH --error=/path/to/iHBCAv1_upload/publication/logs/enrich_prereqs_%j.err

# Phase 0 prerequisites: parse GTF + re-stage L1 metadata

set -euo pipefail

REPO_ROOT="/path/to/iHBCAv1_upload"
SCRIPTS="${REPO_ROOT}/publication/scripts"
CONTAINER="/dfs8/singularity_containers/rcic/devel/Jupyter_R_4.4.2_Giotto_Spatial_Python_2025Q2.sif"

echo "============================================="
echo "Phase 0: Prerequisites"
echo "  Date: $(date)"
echo "  Node: $(hostname)"
echo "============================================="

module load singularity

# 0b. Parse GTF
echo ""
echo "--- Step 1: Parse GENCODE v24 GTF ---"
singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    "$CONTAINER" \
    python3 "${SCRIPTS}/parse_gtf.py" \
        --gtf "${REPO_ROOT}/publication/mappings/gencode.v24.annotation.gtf" \
        --output "${REPO_ROOT}/publication/mappings/gencode_v24_gene_annotations.tsv"

echo ""
echo "Verifying GTF parse output:"
wc -l "${REPO_ROOT}/publication/mappings/gencode_v24_gene_annotations.tsv"
head -3 "${REPO_ROOT}/publication/mappings/gencode_v24_gene_annotations.tsv"

# 0c. Re-stage L1 metadata
echo ""
echo "--- Step 2: Re-stage L1 metadata (18 -> 21 obs columns) ---"
singularity exec \
    --no-mount bind-paths \
    --bind /path/to/shared_data:/path/to/shared_data:ro \
    --bind /path/to/workspace:/path/to/workspace:rw \
    --bind /dfs7:/dfs7:ro \
    --bind /dfs8:/dfs8:ro \
    "$CONTAINER" \
    python3 "${SCRIPTS}/stage_l1_metadata.py" \
        --repo-root "$REPO_ROOT"

echo ""
echo "Verifying L1 output:"
head -1 "${REPO_ROOT}/publication/config/metadata_stages/L1_harmonized_donor.csv" | tr ',' '\n' | wc -l
echo "columns in L1 CSV"

echo ""
echo "============================================="
echo "Phase 0 COMPLETE"
echo "Date: $(date)"
echo "============================================="
