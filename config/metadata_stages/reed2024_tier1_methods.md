# Reed 2024 Tier 1 Dataset Methods

**Paper**: Reed AD, Pensa S, Stegle O, et al. "A single-cell atlas enables mapping of homeostatic cellular shifts in the adult human breast." Nature Genetics 56, 652-662 (2024).
**DOI**: 10.1038/s41588-024-01688-9
**ArrayExpress**: E-MTAB-13664
**CxG Collection**: https://cellxgene.cziscience.com/collections/48259aa8-f168-4bf5-b797-af8e88da6637
**GitHub**: https://github.com/MarioniLab/hbca
**CellTypist models**: https://doi.org/10.5281/zenodo.10044650

## Tracker Fields

| Field | Value | Confidence | Evidence | Source |
|-------|-------|------------|----------|--------|
| study_pi | Walid T. Khaled, John C. Marioni | high | "Correspondence to John C. Marioni or Walid T. Khaled"; "J.C.M. and W.T.K. conceptualized and supervised the study" | Corresponding authors section; Author contributions |
| contact_email | wtk22@cam.ac.uk; marioni@ebi.ac.uk | high | Mailto links on corresponding author names | Paper corresponding authors section |
| sequencing_platform | Illumina NovaSeq 6000 | high | "Pools were sequenced on an Illumina NovaSeq6000 sequencer" | Methods > Library preparation and sequencing |
| assay_ontology_term_id | EFO:0009922 | high | "Chromium Single Cell 3' Library and Gel Bead Kit v3, Chromium Chip B Kit and Chromium Single Cell 3' Reagent Kits v3 User Guide (Manual Part CG000183 Rev C; 10X Genomics)" | Methods > Library preparation and sequencing |
| assay_ontology_term | 10x 3' v3 | high | Same as above -- 10x Chromium 3' v3 kit | Methods > Library preparation and sequencing |
| reference_genome | GRCh38 | high | "reads were aligned to the 10X reference genome GRCh38 (ref-2020-A)" | Methods > Processing and quality control of scRNA-seq data |
| alignment_software | Cell Ranger v6.0.2 | high | "CellRanger Single-Cell Software Suite (v6.0.2) to perform barcode assignment, demultiplexing and unique molecular identifier (UMI) quantification" | Methods > Processing and quality control of scRNA-seq data |
| gene_annotation_version | GENCODE v32 / Ensembl 98 | medium | Not explicitly stated in paper. Inferred from 10x ref-2020-A reference package which bundles GENCODE v32 (Ensembl 98). The 10x documentation for ref-2020-A confirms this annotation version. | Inference from "GRCh38 (ref-2020-A)" in Methods |
| sequenced_fragment | 3 prime tag | high | "28 bp, read 1; 8 bp, i7 index; and 91 bp, read 2" -- standard 10x 3' protocol read configuration | Methods > Library preparation and sequencing |
| intron_inclusion | no | medium | CellRanger v6.0.2 default is exon-only counting (--include-introns not default until v7.0). No mention of intron inclusion anywhere in Methods or GitHub code. | Inference from CellRanger v6.0.2 default behavior |
| ambient_count_correction | none | high | No mention of SoupX, CellBender, DecontX, or any ambient RNA correction tool anywhere in Methods, GitHub code, or supplemental materials. | Methods (exhaustive search); GitHub repo code/analysis/ pipeline |
| doublet_detection | Scrublet v0.2.3 | high | "We applied Scrublet (v0.2.3) in combination with an over-clustering approach by Pijuan-Sala et al. to computationally detect and remove doublets per sample"; GitHub code comments confirm "scrublet==0.2.3" | Methods > Processing and quality control; GitHub code/analysis/03_doublets/03a_doublet_detection.py |
| batch_conditions | processing_date | high | "Samples were divided into 45 batches (labeled by processing date in adata/sce object)" | Methods > Batch design |
| default_embedding | umap | high | Standard for CxG deposits; paper uses UMAP throughout | CxG deposit convention |
| description | Single-cell RNA sequencing atlas of the adult human breast from 55 female donors (reduction mammoplasties and risk reduction mastectomies), identifying 41 cell subtypes across epithelial, immune, and stromal compartments with analysis of age-, parity-, and germline-mutation-dependent effects on cellular composition. | high | Derived from abstract and results summary | Paper abstract |
| publication_doi | 10.1038/s41588-024-01688-9 | high | Verified by navigating to https://www.nature.com/articles/s41588-024-01688-9 | Nature website |

## Additional Processing Details

| Detail | Value | Source |
|--------|-------|--------|
| Cell calling | emptyDrops from DropletUtils v1.12.1, FDR < 0.001 | Methods > Processing and quality control |
| QC thresholds | UMIs < 600 removed; mitochondrial content > 15% removed | Methods > Processing and quality control |
| Spike-in demultiplexing | Vireo v0.5.6 | Methods > Processing and quality control |
| Genotyping | Used for donor demultiplexing | Methods > Genotyping |
| Batch correction | Harmony (for visualization) | Methods |
| Clustering | Leiden algorithm via scanpy | Methods; GitHub code/analysis/04_scanpy |
| Scanpy version | 1.8.1 | GitHub code/analysis/03_doublets/03a_doublet_detection.py (comments) |
| Anndata version | 0.7.6 | GitHub code/analysis/03_doublets/03a_doublet_detection.py (comments) |

## Data Availability

- **Raw sequencing data and CellRanger outputs**: ArrayExpress E-MTAB-13664
- **Processed data and iHBCA**: CxG collection 48259aa8-f168-4bf5-b797-af8e88da6637
- **CellTypist models**: Zenodo 10.5281/zenodo.10044650
- **Code**: GitHub https://github.com/MarioniLab/hbca (contributor: AustinReed-1)
- **No GEO accession** -- data deposited in ArrayExpress (EMBL-EBI), not NCBI GEO

## Notes

1. **gene_annotation_version**: While not explicitly stated in the paper text, the 10x ref-2020-A reference package is well-documented as containing GENCODE v32 (Ensembl 98) annotations. This is a standard inference for 10x-based studies using this reference.

2. **intron_inclusion**: CellRanger v6.0.2 uses exon-only counting by default. The --include-introns flag became default only in CellRanger v7.0+. The paper and GitHub code make no mention of intron inclusion, supporting the "no" determination.

3. **ambient_count_correction**: The analysis pipeline on GitHub (code/analysis/) shows steps 01_genotyping -> 02_quality_control -> 03_doublets -> 04_scanpy with no ambient RNA correction step. The paper methods also make no mention of any ambient correction tool.

4. **Cell calling**: Note that cell calling used emptyDrops (DropletUtils) rather than CellRanger's default cell calling. This is a more sophisticated approach that uses statistical testing against the ambient RNA profile.

## Sources Consulted

- Nature article: https://www.nature.com/articles/s41588-024-01688-9 (Methods sections: Human tissues, Batch design, Mammary gland dissociation, scRNA-seq, Library preparation and sequencing, Processing and quality control, Corresponding authors, Author contributions)
- ArrayExpress: https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-13664
- GitHub repository: https://github.com/MarioniLab/hbca (code/analysis/03_doublets/03a_doublet_detection.py -- confirmed scrublet==0.2.3, scanpy==1.8.1, CellRanger output paths)
- CxG collection page (data deposit confirmation)
