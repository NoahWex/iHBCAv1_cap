# Twigger 2022 Tier 1 Dataset Methods

**Paper**: Twigger AJ, Engelbrecht LK, Bach K, et al. "Transcriptional changes in the mammary gland during lactation revealed by single cell sequencing of cells from human milk." Nature Communications 13, 562 (2022).
**DOI**: 10.1038/s41467-021-27895-0
**PMCID**: PMC8799659
**Data repository**: ArrayExpress E-MTAB-9841 (Batch 1), E-MTAB-10855 (Batch 2), E-MTAB-10885 (Batch 3)
**Code**: https://github.com/aleciajane/LactatingMammaryCells

## Tracker Fields

| Field | Value | Confidence | Evidence | Source |
|-------|-------|------------|----------|--------|
| study_pi | Walid T. Khaled; Christina H. Scheel | high | "These authors jointly supervised this work: Christina H. Scheel, Walid T. Khaled." Both listed as corresponding authors. | PMC article footnotes |
| contact_email | ajt215@cam.ac.uk | high | Twigger is first + corresponding author; email listed in Contributor Information and ArrayExpress submitter info. Also: wtk22@cam.ac.uk (Khaled), christina.scheel@klinikum-bochum.de (Scheel). | PMC Contributor Information; ArrayExpress E-MTAB-9841 submitter |
| sequencing_platform | Illumina NovaSeq 6000 (Batches 1-2); Illumina HiSeq 4000 (Batch 3) | high | "The libraries were then pooled and sequenced on a NovaSeq6000 S2" (Batches 1-2). "Batch 3 was prepared in a similar fashion, however, using version 2 chemistry, sequenced on an Illumina HiSeq 4000" | PMC Methods: Library preparation, sequencing and data processing |
| assay_ontology_term_id | EFO:0009922 (Batches 1-2); EFO:0009899 (Batch 3) | high | "Library preparation for batch 1 and 2 was performed 10x Chromium single-cell kit using version 3 chemistry" -> EFO:0009922 (10x 3' v3). "Batch 3 was prepared in a similar fashion, however, using version 2 chemistry" -> EFO:0009899 (10x 3' v2). ArrayExpress protocol P-MTAB-103886 confirms "Single Cell 3' Reagent Kit v3". | PMC Methods; ArrayExpress P-MTAB-103886, P-MTAB-103887 |
| assay_ontology_term | 10x 3' v3 (Batches 1-2); 10x 3' v2 (Batch 3) | high | Same evidence as assay_ontology_term_id. | PMC Methods |
| reference_genome | GRCh38 (likely; see notes) | medium | Paper Methods state "hg19 reference genome" but ArrayExpress protocol P-MTAB-103889 states "human genome Ensembl release 94" which is GRCh38. Cell Ranger 3.0.2 pre-built references from 10x Genomics website use GRCh38. The hg19 claim in the paper is likely an error. See Notes section. | PMC Methods (hg19 claim); ArrayExpress P-MTAB-103889 (Ensembl 94 / GRCh38) |
| alignment_software | Cell Ranger 3.0.2 (Batches 1-2); Cell Ranger 2.1.1 (Batch 3) | high | "Read processing was performed using the 10x Genomics workflow using the Cell Ranger Single-Cell Suite version 3.0.2" (Batches 1-2). "Batch 3... read processing was done using Cell Ranger Single-Cell Suite version 2.1.1." ArrayExpress P-MTAB-103889 confirms "Cell Ranger version 3.0.2". | PMC Methods; ArrayExpress P-MTAB-103889 |
| gene_annotation_version | Ensembl 94 (Batches 1-2) | medium | ArrayExpress protocol P-MTAB-103889: "using the human genome Ensembl release 94 as a reference." Not stated in paper text. For Batch 3 (Cell Ranger 2.1.1), the bundled reference was likely an older Ensembl release but not explicitly documented. | ArrayExpress P-MTAB-103889 |
| sequenced_fragment | 3 prime tag | high | 10x Chromium 3' chemistry used for all batches. "10x Chromium single-cell kit using version 3 chemistry" (3' kit). | PMC Methods |
| intron_inclusion | no | medium | Not explicitly stated. Cell Ranger 3.0.2 and 2.1.1 default to exon-only counting (include-introns option not available until Cell Ranger 7.0). | Inference from Cell Ranger version |
| ambient_count_correction | emptyDrops (DropletUtils) | high | "Barcodes identified as containing low counts of UMIs likely resulting from ambient RNA were removed using the function 'emptyDrops' from the DropletUtils package." Confirmed in GitHub code: Batch1/1_B1_prepareExpressionList.Rmd calls emptyDrops(counts(sce)) with FDR <= 0.01. Note: emptyDrops identifies empty droplets rather than correcting ambient counts in retained cells (unlike SoupX/CellBender). | PMC Methods: QC and data pre-processing; GitHub src/1_Individual_batches/Batch1/1_B1_prepareExpressionList.Rmd |
| doublet_detection | none | high | No mention of doublet detection in Methods section or anywhere in paper. GitHub repository code contains no doublet detection scripts. Full-text search for "doublet" returns zero hits in Methods. | PMC full text; GitHub repo (all scripts reviewed) |
| batch_conditions | library_preparation_batch | high | Three batches with distinct library prep dates, chemistry versions, and sequencing platforms. Methods describe per-batch QC and batch correction via fastMNN. "Batch effects were removed by the application of the fastMNN function from the batchelor package." | PMC Methods; SRA run table confirms B1/B2/B3 assignment |
| description | Single-cell RNA sequencing of 110,744 cells from human milk and non-lactating breast tissue across 16 donors (9 lactating, 7 non-lactating), characterizing mammary epithelial and immune cell transcriptional changes during lactation using 10x Chromium 3' chemistry. | high | Cell count from abstract. Donor count from Methods. | PMC abstract and Methods |
| publication_doi | 10.1038/s41467-021-27895-0 | high | DOI from paper header. | PMC article |

## Notes

### Reference genome discrepancy (hg19 vs GRCh38)

The paper Methods state alignment was to "the hg19 reference genome using the pre-built annotation package obtained from the 10x Genomics website." However, ArrayExpress protocol P-MTAB-103889 (submitted by the authors) states "using the human genome Ensembl release 94 as a reference." Ensembl 94 (released October 2018) uses GRCh38, not hg19/GRCh37.

Additionally, the 10x Genomics pre-built references for Cell Ranger 3.0.2 (released mid-2019) default to GRCh38 (Ensembl 93). There was no pre-built hg19 reference available from 10x for Cell Ranger 3.x; one would have had to build a custom reference to use hg19.

Most likely explanation: The paper incorrectly states "hg19" when GRCh38 was actually used. The ArrayExpress submission (which was presumably filled out closer to the actual analysis) is more reliable for this detail. The reference should be reported as GRCh38 with Ensembl 94 annotations.

For Batch 3 (Cell Ranger 2.1.1), the situation is less clear. Cell Ranger 2.1.1 pre-built references did support hg19 (with Ensembl 85 annotations). However, the paper states hg19 was used for alignment across all batches, and the ArrayExpress protocol for Batch 1 specifies Ensembl 94 / GRCh38. It is plausible that Batch 3 used a different reference than Batches 1-2, but this cannot be confirmed from available documentation.

**Recommendation**: Report as GRCh38 / Ensembl 94 for Batches 1-2, flag Batch 3 as uncertain (possibly hg19/Ensembl 85 or GRCh38/Ensembl 94). Contact authors for clarification if needed.

### Ambient RNA handling nuance

The emptyDrops function from DropletUtils identifies and removes empty droplets (those containing only ambient RNA) but does not perform ambient RNA correction/decontamination on the retained cell-containing droplets. This is distinct from tools like SoupX or CellBender which estimate and subtract ambient contamination from retained cells. For tracker purposes, "emptyDrops (DropletUtils)" should be reported for the ambient_count_correction field, but it should be understood as empty droplet filtering rather than per-cell ambient correction.

### Batch 3 chemistry and sequencer

Batch 3 used 10x Chromium 3' v2 chemistry (not v3 like Batches 1-2) and was sequenced on HiSeq 4000 (not NovaSeq 6000). This means cells from Batch 3 should carry EFO:0009899 (10x 3' v2) rather than EFO:0009922 (10x 3' v3). In the existing iHBCA CxG h5ad, per-cell assay terms should reflect this batch difference.

### Data repository

Data is on ArrayExpress (EBI), NOT GEO/SRA. Three accessions for three batches:
- E-MTAB-9841: Batch 1 (LMC1-4, NMC1-4)
- E-MTAB-10855: Batch 2 (LMC2B, LMC5-8, NMC5-7)
- E-MTAB-10885: Batch 3 (LMC9, NMC1B)

ENA project: ERP125479

## Source

- PMC full text: PMC8799659 (https://pmc.ncbi.nlm.nih.gov/articles/PMC8799659/)
- ArrayExpress: E-MTAB-9841 (https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-9841)
- GitHub: https://github.com/aleciajane/LactatingMammaryCells (src/1_Individual_batches/Batch1/1_B1_prepareExpressionList.Rmd confirmed emptyDrops usage)
- Extracted 2026-03-18
