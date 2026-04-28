# Gray 2022 - Tier 1 Dataset Metadata (Methods-Derived)

Source: Gray GK et al., "A human breast atlas integrating single-cell proteomics and transcriptomics" Dev Cell 2022.
PMC: PMC9202341 | DOI: 10.1016/j.devcel.2022.05.003 | PMID: 35617956
GEO: GSE180878 | SRA: SRP329970

## Metadata Fields

| Field | Value | Confidence | Source / Evidence |
|-------|-------|------------|-------------------|
| dataset_id | gray2022 | -- | Project identifier |
| consortia | unknown | high | Not part of HCA or similar consortium; Brugge lab at HMS, NIH/NCI funded |
| study_pi | Joan S. Brugge | high | PMC author list: "Lead Contact" designation; Correspondence section |
| contact_email | joan_brugge@hms.harvard.edu | high | PMC: "Correspondence: joan_brugge@hms.harvard.edu"; GEO contact matches |
| batch_conditions | donor_id | high | STAR Methods: SCTransform regression on nCount_RNA, percent.mt, S.Score, G2M.Score; donor used as covariate in edgeR differential analyses |
| default_embedding | umap | high | STAR Methods: "Clustered cells were visualized by UMAP embedding using the default settings in Seurat" |
| sequencing_platform | Illumina HiSeq X Ten | high | STAR Methods: "Libraries were sequenced by Illumina HiSeq X Ten"; GEO platform GPL20795 confirms |
| assay_ontology_term_id | EFO:0009899 | high | 10x 3' v2 chemistry maps to EFO:0009899 (10x 3' v2) |
| assay_ontology_term | 10x 3' v2 | high | STAR Methods: "10X Chromium 3' library construction kit v2 following the manufacturer's instructions" |
| reference_genome | GRCh38 | high | STAR Methods: "mapped to the GRCh38-3.0.0 human genome using Cell Ranger v3.0" |
| alignment_software | Cell Ranger v3.0 | high | STAR Methods: "using Cell Ranger v3.0"; Key Resources Table: "Cell Ranger (v3)" |
| intron_inclusion | no | high | Cell Ranger v3.0 default is exon-only counting (pre-v7 include-introns default) |
| ambient_count_correction | none | high | No SoupX/CellBender/DecontX in STAR Methods, Key Resources Table, or GEO. Physical mitigation only: "including 3 washes to minimize ambient RNA" (STAR Methods) |
| doublet_detection | none (manual) | high | No Scrublet/DoubletFinder in STAR Methods, Key Resources Table, or GEO. Figure 1A legend: subclusters "discarded as potential doublets due to unusually high gene counts and aberrant marker expression" |
| sequenced_fragment | 3 prime tag | high | 10x Chromium 3' library = 3' end sequencing |
| gene_annotation_version | GRCh38-3.0.0 (Ensembl 93 / GENCODE v29) | high | Cell Ranger pre-built reference package GRCh38-3.0.0 bundles Ensembl 93 annotations (GENCODE v29) |
| description | Single-cell RNA-seq atlas of 52,681 normal human breast cells from 16 donors, profiling epithelial and stromal cell types and subtypes across age, parity, and BRCA1/2 mutation status. | high | Derived from abstract and GEO summary |
| publication_doi | 10.1016/j.devcel.2022.05.003 | high | PMC article metadata |

## Verification Sources Checked

1. **STAR Methods (PMC full text, PMC9202341)** -- Primary source for all processing fields. Section: "Single-Cell RNA-Sequencing Sample Preparation and Data Analysis."
2. **Key Resources Table (PMC9202341)** -- Software list: R v3.5.1/4.0.1, Cell Ranger v3, Seurat v3/v4, edgeR v3.24.3, Python v3.8, Prism v9. No doublet detection or ambient RNA correction tools listed.
3. **GEO (GSE180878)** -- Confirms platform (GPL20795 = HiSeq X Ten), 16 samples, contact info. No processing README or additional method notes. Supplementary files: count matrix CSV + metadata CSV.
4. **Data Availability section** -- "Scripts for computational analyses are available as Data S2" (supplementary zip). No GitHub repository or Zenodo deposit for analysis code.
5. **No GitHub repo** -- Only GitHub link in paper is ASHLAR (labsyspharm/ashlar) for CyCIF imaging, unrelated to scRNA-seq processing.

## Key Notes

- **GRCh38-3.0.0** is the Cell Ranger pre-built reference package name, corresponding to GRCh38 genome with Ensembl 93 gene annotations (GENCODE v29).
- **No formal doublet detection** software was used. Suspicious clusters were manually removed based on high gene counts and aberrant marker expression (noted in Figure 1A legend).
- **No computational ambient RNA correction** was applied. The study relied on physical washes (3x) during library preparation to minimize ambient RNA.
- **Batch correction** was handled via SCTransform regression (nCount_RNA, percent.mt, S.Score, G2M.Score) rather than integration tools like Harmony or BBKNN. Donor ID was used as a covariate in edgeR differential analyses.
- The paper originates from Harvard Medical School (Brugge lab), not formally part of the HCA consortium, though the data is available on CellxGENE.
- Data deposited at SRA: SRP329970, GEO: GSE180878, Single Cell Portal: SCP1731.
- Analysis software: Seurat v3/v4, edgeR v3.24.3, Python v3.8, R v3.5.1/4.0.1.
