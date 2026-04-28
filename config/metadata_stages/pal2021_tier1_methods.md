# Pal 2021 Tier 1 Dataset Methods

**Paper**: Pal B, Chen Y, Vaillant F, Capaldo BD, Joyce R, Song X, Bryant VL, Penington JS, Di Stefano L, Tubau Ribera N, Wilcox S, Mann GB; kConFab; Papenfuss AT, Lindeman GJ, Smyth GK, Visvader JE. "A single-cell RNA expression atlas of normal, preneoplastic and tumorigenic states in the human breast." EMBO J. 2021 Jun 1;40(11):e107333.
**DOI**: 10.15252/embj.2020107333
**PMID**: 33950524
**PMCID**: PMC8167363
**GEO**: GSE161529 (scRNA-seq), GSE161892 (bulk RNA-seq)
**BioProject**: PRJNA678650
**Companion paper**: Chen Y, Pal B, Lindeman GJ, Visvader JE, Smyth GK. "R code and downstream analysis objects for the scRNA-seq atlas of normal and tumorigenic human breast tissue." Sci Data. 2022 Mar 23;9(1):96. PMID: 35322042. PMCID: PMC8943201.
**Code**: https://github.com/yunshun/HumanBreast10X
**Figshare**: 10.6084/m9.figshare.17058077

## Tracker Fields

| Field | Value | Confidence | Evidence | Source |
|-------|-------|------------|----------|--------|
| study_pi | Jane E Visvader; Gordon K Smyth | high | Both listed as corresponding authors on PMC. Visvader: ACRF Cancer Biology & Stem Cells Division, WEHI. Smyth: Bioinformatics Division, WEHI. | PMC author list, ref_308-310 |
| contact_email | visvader@wehi.edu.au; smyth@wehi.edu.au | high | Both listed on PMC article. GEO contact is smyth@wehi.edu.au. Also dataaccess@wehi.edu.au mentioned in Data Availability. | PMC contributor info; GEO GSE161529 |
| sequencing_platform | Illumina NextSeq 500 | high | GEO platform GPL18573 = "Illumina NextSeq 500 (Homo sapiens)". GEO sample GSM4909253: "Instrument model: Illumina NextSeq 500". | GEO GSE161529 platform; GEO GSM4909253 |
| assay_ontology_term_id | EFO:0009899 | medium | 10x 3' v2. Paper says "Single Cell 3' Protocol" without specifying v2 or v3. GEO extraction protocol says "cDNA was prepared using the Single Cell 3' Protocol recommended by the manufacturer" with no version. Cell Ranger 3.0.2 supports both v2 and v3. No raw data deposited to check read lengths (v2=26+98bp, v3=28+91bp). The efo_assay_mapping.tsv maps to v2 (EFO:0009899) reasoning that v2 is most likely given data collection timing (pre-2020) and Cell Ranger 3.0.2 era. CANNOT be definitively resolved without contacting authors or checking raw FASTQ read lengths. | PMC methods; GEO GSM4909253 extraction protocol; efo_assay_mapping.tsv |
| assay_ontology_term | 10x 3' v2 | medium | See assay_ontology_term_id notes above. | Same as above |
| reference_genome | GRCh38 | high | Chen et al. 2022 companion paper: "genewise read counts were obtained using 'cellranger count' with the Cell Ranger human GRCh38 reference v3.0.0". GEO GSM4909253: "Genome_build: GRCh38". | Chen et al. Sci Data 2022 (PMC8943201); GEO GSM4909253 |
| alignment_software | Cell Ranger 3.0.2 | high | Chen et al. 2022: "Cell Ranger v3.0.2". GEO GSM4909253: "Read alignment and count summarization were performed using CellRanger v3.0.2". PMC methods: "Cell Ranger 3.0.2". | Chen et al. Sci Data 2022; GEO GSM4909253; PMC methods |
| gene_annotation_version | Ensembl 93 | high | Cell Ranger GRCh38 reference v3.0.0 bundles Ensembl 93 (GENCODE v29) annotations. This is the standard, well-documented mapping for this reference build. Post-alignment, gene symbols were re-annotated: "converted to current HUGO symbols and Entrez Gene IDs using limma's alias2SymbolUsingNCBI function and NCBI gene annotation dated 18 Aug 2018" (PMC methods). The Ensembl 93 annotation is what determines the gene set in the count matrix. | Cell Ranger ref v3.0.0 spec (10x docs); PMC methods for post-processing |
| sequenced_fragment | 3 prime tag | high | GEO extraction protocol: "cDNA was prepared using the Single Cell 3' Protocol". PMC methods: "Single Cell 3' Protocol". | GEO GSM4909253; PMC methods |
| intron_inclusion | no | high | Cell Ranger 3.0.2 default excludes introns (pre-mRNA reference not used). No mention of intron inclusion or pre-mRNA mode in paper, companion paper, or GEO. Pre-mRNA mode was opt-in and not standard practice in 2018-2020. | Cell Ranger 3.0.2 defaults; absence in all sources |
| ambient_count_correction | none | high | No mention of SoupX, CellBender, DecontX, or any ambient RNA correction in paper, companion paper (Chen et al. 2022), or GitHub code. QC.R script shows standard filtering only. | PMC methods; Chen et al. 2022; GitHub yunshun/HumanBreast10X |
| doublet_detection | none | medium | No formal doublet detection tool (Scrublet, DoubletFinder, scDblFinder) mentioned. Methods describe manual QC filtering: "Cells with exceptionally high numbers of reads or genes detected were also filtered to minimize the occurrence of doublets." This is threshold-based QC, not algorithmic doublet detection. | PMC methods |
| batch_conditions | unknown | low | No explicit batch variable documented. 69 samples across 52 patients were processed individually through Cell Ranger. Seurat anchor-based integration was used to combine samples. No information on which samples were run in the same 10x chip channel or sequencing run. | PMC methods; GEO |
| description | Single-cell RNA expression atlas of over 340,000 cells from normal breast tissue, preneoplastic BRCA1+/- tissue, and primary breast tumors spanning ER+, HER2+, and triple-negative subtypes from 52 patients. | high | Derived from abstract and GEO summary. GEO: "69 scRNA-seq profiles using the 10X Genomics Chromium platform, comprising a total of 421,761 cells from 52 patients." | PMC abstract; GEO GSE161529 |
| publication_doi | 10.15252/embj.2020107333 | high | EMBO J. 2021 Jun 1;40(11):e107333. | PMC, PubMed |

## Chemistry Version Analysis (v2 vs v3)

This is the key unresolved uncertainty. Evidence for and against each:

**Evidence favoring v2 (EFO:0009899)**:
- Cell Ranger 3.0.2 was released Oct 2018, when v2 was still the dominant chemistry
- Data collection likely 2018-2019 (paper submitted Nov 2020)
- The GEO extraction protocol language ("Single Cell 3' Protocol") matches the v2 user guide (CG00052) more than the v3 guide (CG000183)
- v3 chemistry was brand new in late 2018; Australian labs may not have adopted it immediately
- The efo_assay_mapping.tsv currently maps to v2

**Evidence favoring v3 (EFO:0009922)**:
- v3 was available from late 2018
- Some samples could have been processed with v3 if data collection extended into 2019

**Cannot resolve because**:
- Paper says only "Single Cell 3' Protocol" without version
- No raw FASTQ data deposited (GEO states "Raw data not provided for this record")
- SRA has no runs for this project (no raw data)
- Read length would distinguish v2 (26bp barcode + 98bp insert) vs v3 (28bp barcode + 91bp insert)
- Neither companion paper nor GitHub code specifies chemistry version

**Recommendation**: Keep EFO:0009899 (v2) as the best estimate. Flag for author confirmation if feasible.

## Reference Genome Details

The Cell Ranger GRCh38 reference v3.0.0 is a specific, well-documented build:
- Genome: GRCh38 (hg38)
- Gene annotations: Ensembl 93 (equivalent to GENCODE v29)
- Includes the standard 10x filtering of non-poly-A transcripts
- This was confirmed by the companion paper (Chen et al. 2022)

Post-alignment gene symbol re-annotation was performed using NCBI gene annotation dated 18 Aug 2018 via limma's alias2SymbolUsingNCBI function. This affects gene naming but not the underlying Ensembl gene set.

## Data Availability Note

Raw sequencing data (FASTQ/BAM) was NOT deposited. GEO states: "Raw data not provided for this record." Only processed count matrices (MTX format) are available as supplementary files. This means:
- SRA metadata cannot be used to verify chemistry version
- Read length analysis is not possible
- The BioProject PRJNA678650 has no SRA runs

## Sources Consulted

1. PMC full text (PMC8167363) - Methods sections
2. GEO series page (GSE161529)
3. GEO sample page (GSM4909253) - extraction protocol, data processing
4. Chen et al. 2022 companion paper (PMC8943201) - Cell Ranger reference version
5. GitHub repository (yunshun/HumanBreast10X) - QC.R and repository structure
6. Figshare deposit (10.6084/m9.figshare.17058077) - referenced but not directly checked
7. efo_assay_mapping.tsv - existing project mapping
