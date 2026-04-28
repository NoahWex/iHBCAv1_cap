# Kumar 2023 Tier 1 Dataset Methods

## Tracker Fields

| Field | Value | Confidence | Notes |
|-------|-------|------------|-------|
| study_pi | Nicholas Navin; Kai Kessenbrock; Devon A Lawson | high | Three corresponding authors on PubMed (PMID 37380767). CxG collection contact listed as Nicholas Navin. |
| contact_email | nnavin@mdanderson.org; kai.kessenbrock@uci.edu; dalawson@uci.edu | high | PubMed corresponding author emails for all three corresponding authors. |
| sequencing_platform | Illumina NovaSeq 6000; Illumina HiSeq 4000 | high | Methods: "NovaSeq 6000 system S2-100 flowcell (Illumina)". GEO GSE195665 lists two platforms: GPL24676 (NovaSeq 6000) and GPL20301 (HiSeq 4000). Mixed platforms across samples. |
| assay_ontology_term_id | EFO:0009899; EFO:0009922 | high | Mixed chemistries per Methods: "Single Cell Chromium 3' protocols (V2: CG00052, V3: CG000183, V3.1: CG000204)". CxG deposit lists 10x 3' v2 and 10x 3' v3 per cell. EFO:0009899 = 10x 3' v2, EFO:0009922 = 10x 3' v3. CxG does not distinguish v3 from v3.1 (both map to EFO:0009922). Per-cell assignment in existing CxG deposit. |
| reference_genome | GRCh38 | high | Methods: "aligned to the GRCh38.p12 human genome reference". GitHub cellranger_script_single_cell_example.sh confirms --transcriptome refdata-cellranger-GRCh38-3.0.0. |
| alignment_software | Cell Ranger v3.1.0 | high | Methods: "CellRanger pipeline (v.3.1.0, 10x Genomics)". GitHub README confirms: "Samples were processed using cell ranger 3.1.0 using refdata-cellranger-GRCh38-3.0.0". GitHub cellranger_script_single_cell_example.sh shows explicit path to cellranger-3.1.0. |
| gene_annotation_version | Ensembl 93 | high | GitHub README and cellranger_script_single_cell_example.sh confirm reference is refdata-cellranger-GRCh38-3.0.0. 10x Reference Release Notes state the 2020-A reference "updated from Ensembl 93 to GENCODE v32", confirming all pre-2020-A references (including 3.0.0) use Ensembl 93. Not GENCODE v32 as previously inferred. |
| sequenced_fragment | 3 prime tag | high | Methods: "10x Genomics Single Cell Chromium 3' protocols (V2: CG00052, V3: CG000183, V3.1: CG000204)". |
| intron_inclusion | no | high | GitHub cellranger_script_single_cell_example.sh shows no --include-introns flag. CellRanger 3.1.0 does not include introns by default. Reference used is refdata-cellranger-GRCh38-3.0.0 (standard exonic reference, not pre-mRNA). Applies to both scRNA-seq and snRNA-seq components (same pipeline per Methods). Note: snRNA-seq without intron inclusion reduces nuclear gene detection sensitivity. |
| ambient_count_correction | none | high | No SoupX, CellBender, DecontX, or any ambient RNA correction in Methods text, GitHub code (navinlabcode/HumanBreastCellAtlas), or supplementary materials. Verified: 00_load_packages.R, 01_read_files.R, 00_functions_final1.R contain zero ambient RNA tool references. |
| doublet_detection | none (manual threshold + post-clustering QC) | high | Two-phase manual approach: (1) Pre-clustering: cells with >20,000 UMIs or >5,000 genes removed as potential doublets (Methods text; GitHub 01_read_files.R lines 119-126 confirms nCount_RNA<20000, nFeature_RNA<5000). (2) Post-clustering: 3-step QC per cluster -- outlier QC metrics (>2 SD), mito/ribo/hemoglobin marker clusters removed, cross-cell-type marker co-expression clusters flagged as doublets (Methods "Clustering of major cell types"; GitHub 03_remove_doublets_recluster.R confirms clusters 15-20 removed). No Scrublet, DoubletFinder, or any dedicated doublet software in codebase. |
| batch_conditions | donor_id | medium | Not explicitly stated as batch variable. Inferred from Methods: integration via Seurat CCA (FindIntegrationAnchors) across all samples using sample_id/patient_id grouping. GitHub 02_cluster_integration_core.R performs integration. |
| description | Single-cell and spatial transcriptomic atlas of the adult human breast profiling 714,331 cells from 126 women, identifying 12 major cell types and 58 biological cell states across epithelial, immune, stromal, and vascular compartments. | high | Derived from abstract. CxG collection confirms 714,331 cells for scRNA-seq "all cells" dataset. |
| publication_doi | 10.1038/s41586-023-06252-9 | high | Nature 620, 181-191 (2023). PMID 37380767. |

## Additional Context

- **Consortia**: Funded by CZI SEED Network Grant (CZF2019-002432). Not formally an HCA consortium paper but deposited on CELLxGENE and part of the HCA breast atlas collection.
- **default_embedding**: X_umap (standard for CxG deposits; Methods confirms RunUMAP with dims=1:20).
- **Mixed chemistries**: 10x 3' V2, V3, and V3.1 used across different samples per Methods. CxG deposit collapses these to v2 (EFO:0009899) and v3 (EFO:0009922) per cell. Protocol numbers: V2=CG00052, V3=CG000183, V3.1=CG000204.
- **Mixed sequencing platforms**: GEO SuperSeries GSE195665 lists both Illumina HiSeq 4000 (GPL20301) and NovaSeq 6000 (GPL24676). Methods text mentions only NovaSeq 6000.
- **snRNA-seq component**: 117,346 nuclei from 20 women (GEO SubSeries GSE234817). Same CellRanger v3.1.0 pipeline and refdata-cellranger-GRCh38-3.0.0 reference per GitHub. No --include-introns flag in CellRanger script.
- **Data processing pipeline**: CASAVA v1.8.1 for demultiplexing -> CellRanger v3.1.0 for alignment/UMI counting -> Seurat v3.2.3 for downstream analysis (filtering, integration, clustering).
- **GEO SubSeries**: GSE235326 (scRNA-seq cells), GSE234817 (snRNA-seq nuclei), GSE234814 (Visium spatial).
- **Gene annotation correction**: Previous entry listed GENCODE v32/Ensembl 98 (inferred from CellRanger v3.1.0 compatibility). Corrected to Ensembl 93 based on GitHub README confirming refdata-cellranger-GRCh38-3.0.0 and 10x Reference Release Notes documenting the Ensembl 93 -> GENCODE v32 transition in the 2020-A reference.

## Source

- Paper: https://www.nature.com/articles/s41586-023-06252-9
- PubMed: https://pubmed.ncbi.nlm.nih.gov/37380767/
- PMC: https://pmc.ncbi.nlm.nih.gov/articles/PMC11443819/
- GitHub: https://github.com/navinlabcode/HumanBreastCellAtlas (Code availability section of paper)
- GEO: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE195665 (SuperSeries)
- CxG: https://cellxgene.cziscience.com/collections/4195ab4c-20bd-4cd3-8b3d-65601277e731
- 10x Reference Release Notes: https://www.10xgenomics.com/support/software/cell-ranger/latest/release-notes/cr-reference-release-notes
- Methods sections consulted: "scRNA-seq", "snRNA-seq", "Single-cell RNA and nucleus RNA data preprocessing and filtering", "Clustering of major cell types in scRNA-seq and snRNA-seq data", "Code availability", "Data availability"
- GitHub files consulted: README.md, cellranger_script_single_cell_example.sh, R/pre_processing/00_load_packages.R, R/pre_processing/01_read_files.R, R/pre_processing/02_cluster_integration_core.R, R/pre_processing/03_remove_doublets_recluster.R, R/pre_processing/00_functions_final1.R
