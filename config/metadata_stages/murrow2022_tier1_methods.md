# Murrow 2022 Tier 1 Dataset Methods

Paper: "Mapping hormone-regulated cell-cell interaction networks in the human breast at single-cell resolution"
Authors: Murrow LM, Weber RJ, Caruso JA, McGinnis CS, Phong K, Gascard P, Rabadan G, Borowsky AD, Desai TA, Thomson M, Tlsty T, Gartner ZJ
Journal: Cell Systems, 2022 Aug 17; 13(8):644-664.e8
PMID: 35863345 | PMCID: PMC9590200

## Tracker Fields

| Field | Value | Confidence | Notes |
|-------|-------|------------|-------|
| study_pi | Zev J Gartner | high | STAR Methods lead contact: "directed to and will be fulfilled by the lead contact, Zev J. Gartner"; GEO contact: Zev Gartner, UCSF Pharmaceutical Chemistry |
| contact_email | zev.gartner@ucsf.edu | high | STAR Methods lead contact email; GEO contact email. |
| sequencing_platform | Illumina HiSeq 4000, Illumina NovaSeq 6000 | medium | Paper says "HiSeq4500 or NovaSeq" per sample (Table S2) -- HiSeq4500 is not a real Illumina model. GEO platform IDs are GPL20301 (Illumina HiSeq 4000) and GPL24676 (Illumina NovaSeq 6000), which are authoritative. Per-sample assignment in Table S2. |
| assay_ontology_term_id | EFO:0009899, EFO:0009922 | high | Mixed: 10x 3' v2 (EFO:0009899) and 10x 3' v3 (EFO:0009922). KRT lists "Chromium Single Cell 3' Library & Gel Bead Kit v2" and "Chromium Single Cell 3' GEM, Library & Gel Bead Kit v3". Per-sample assignment in Table S2. |
| reference_genome | GRCh37 | high | STAR Methods "Expression library pre-processing": "Data were mapped to the human reference genome GRCh37 (hg19)" |
| alignment_software | Cell Ranger v3.0.2 | high | Key Resources Table: "CellRanger v3.0.2" under Software and algorithms. Methods: "Cell Ranger (10x Genomics) was used to align sequences, filter data and count unique molecular identifiers (UMIs)." |
| gene_annotation_version | Ensembl 87 | medium | Not explicitly stated in paper. Inferred: CellRanger v3.0.2 with GRCh37 reference bundles Ensembl 87 (GENCODE v25lift37). No contradicting information in GitHub, GEO, or Zenodo. |
| sequenced_fragment | 3 prime tag | high | KRT: "Chromium Single Cell 3' Library & Gel Bead Kit v2" (PN-120237) and "Chromium Single Cell 3' GEM, Library & Gel Bead Kit v3" (PN-1000075). Methods: "10X Genomics Single Cell V2 ... or Single Cell V3 ... standard workflows". |
| intron_inclusion | no | high | Standard CellRanger v3.0.2 3' workflow counts exonic reads only. No mention of pre-mRNA reference, intron counting, or --include-introns flag in methods, GitHub, or GEO. |
| ambient_count_correction | none | high | Deep-verified: no SoupX, CellBender, DecontX, or any ambient RNA correction tool mentioned in STAR Methods (all subsections), Key Resources Table, GitHub (lmurrow/DECIPHER-seq), Zenodo (10.5281/zenodo.6596414), or GEO (GSE198732). SoupOrCell used only for genotype-based sample demultiplexing, not ambient correction. |
| doublet_detection | DoubletFinder v2.0 | high | STAR Methods "Dataset integration": "ran DoubletFinder (version 2.0) on each data subset (McGinnis et al., 2019a), using parameters identified by the paramSweep_v3 function". KRT lists "DoubletFinder" with GitHub link. Additional filtering: cells with Z-score >= 4 for total genes also removed as presumed doublets. |
| batch_conditions | 10x chemistry version (v2 vs v3), FACS sort gate, MULTI-seq sample barcoding | medium | Not a single explicit "batch_conditions" statement. Inferred from methods: Batches 1-2 used 10x v2 with individual samples per lane; Batches 3-4 and KTB used 10x v3 with MULTI-seq multiplexing. Sort gates varied: Live/singlet, Epithelial (EpCAM+/Lin-), Luminal, Basal. Per-sample details in Table S2. Integration used SCTransform + CCA across batches. |
| description | Single-cell RNA-seq atlas of the premenopausal human breast from 28 reduction mammoplasty samples (86,136 cells), mapping hormone-regulated cell-cell interaction networks using DECIPHER-seq. | high | Based on abstract and GEO summary. Cell count from GEO: "86,136 cells collected from 28 healthy premenopausal donors". |
| publication_doi | 10.1016/j.cels.2022.06.005 | high | From PubMed/PMC record |

## Additional Notes

- **GEO accession**: GSE198732 (22 GEO samples: Sets 1-17 individual, Sets 18-22 multiplexed)
- **Reference genome is GRCh37 (hg19)**, not GRCh38. This differs from most other iHBCA studies.
- **Mixed assay chemistry**: 10x 3' v2 (Batches 1-2) and v3 (Batches 3-4, KTB) used across different batches.
- **SoupOrCell** was used for genotype-based sample demultiplexing of multiplexed lanes (not ambient RNA correction).
- **MULTI-seq** barcoding was used for sample multiplexing in Batches 3, 4, and KTB.
- **28 donors** from reduction mammoplasty (CHTN and Kaiser Permanente Northern California) plus Komen Tissue Bank core biopsies, processed as epithelial-enriched tissue fragments.
- **GitHub repo** (lmurrow/DECIPHER-seq) contains only DECIPHER-seq downstream analysis code (NMF, network construction, GSEA), not preprocessing pipeline code.
- **Zenodo deposit** (10.5281/zenodo.6596414) is a v1.0.0 archive of the same GitHub repo.
- **GEO supplementary files**: Raw counts (RDS), barcode counts (RDS), metadata (RDS), and integrated breast.data.rds object.

## Source

- PMC full text: https://pmc.ncbi.nlm.nih.gov/articles/PMC9590200/
- PubMed: https://pubmed.ncbi.nlm.nih.gov/35863345/
- GEO: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE198732
- GitHub: https://github.com/lmurrow/DECIPHER-seq (DECIPHER-seq analysis code only; no preprocessing scripts)
- Zenodo: https://doi.org/10.5281/zenodo.6596414 (archive of GitHub repo v1.0.0)
- Methods sections consulted: STAR Methods > Lead Contact, scRNA-seq library preparation, Expression library pre-processing, Cell calling, MULTI-seq barcode library pre-processing, Sample demultiplexing, Dataset integration and cell type identification; Key Resources Table (Software and algorithms, Deposited data, Critical commercial assays)
- Deep verification (2026-03-18): All fields checked against PMC full text, GEO (GSE198732), GitHub (lmurrow/DECIPHER-seq), and Zenodo (10.5281/zenodo.6596414).
