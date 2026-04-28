# Nee 2023 Tier 1 Dataset Methods

## Tracker Fields

| Field | Value | Confidence | Notes |
|-------|-------|------------|-------|
| study_pi | Kai Kessenbrock | high | Corresponding author (affiliation 9), UCI Dept of Biological Chemistry. PubMed lists "kai.kessenbrock@uci.edu" as corresponding author. PMC10655552 confirms. |
| contact_email | kai.kessenbrock@uci.edu | high | Listed as corresponding author email in PubMed (PMID 36914836) and Nature article. |
| sequencing_platform | Illumina HiSeq4000, Illumina NovaSeq6000 | high | Methods: "The Illumina HiSeq4000 and NovaSeq6000 platforms were used to achieve an average of 50,000 reads per cell." Note: GEO GSE174588 lists only GPL24676 (NovaSeq 6000) as the platform, which is a GEO metadata omission. Paper is authoritative. |
| assay_ontology_term_id | EFO:0009899 (10x 3' v2); EFO:0009901 (10x 3' v1) | high | Methods: "10X Genomics v1 chemistry (sample IDs: noncarrier 1; BRCA1+/mut 1) was performed following the Chromium Single Cell 3' Reagents Kits User Guide: CG00026 Rev B. Library generation for 10X Genomics v2 chemistry (sample IDs: noncarrier 2-11; BRCA1+/mut 2-11) was performed following the Chromium Single Cell 3' Reagents Kits v2 User Guide: CG00052 Rev B." EFO:0009901 confirmed as "10x 3' v1" via EBI OLS. EFO:0009899 = "10x 3' v2". Per-cell assignment needed: v1 for 2 samples, v2 for 20 samples. Note: CxG schema 5.3.0 recommended values only list v2/v3/v4, not v1; EFO:0009901 is valid but may need special handling. |
| reference_genome | GRCh38 | high | Methods: "alignment was performed using 10X Cell Ranger v3.1 to the GRCh38 reference." |
| alignment_software | Cell Ranger v3.1 | high | Methods: "alignment was performed using 10X Cell Ranger v3.1 to the GRCh38 reference." |
| gene_annotation_version | Ensembl 93 (GENCODE v29) | medium | Not explicitly stated in paper, supplementary materials, or GEO. Inferred from Cell Ranger v3.1 default reference bundle (refdata-cellranger-GRCh38-3.0.0 uses Ensembl 93 / GENCODE v29). No custom reference mentioned. |
| sequenced_fragment | 3 prime tag | high | Methods: "Chromium Single Cell 3' Reagents Kits" for both v1 (CG00026 Rev B) and v2 (CG00052 Rev B). |
| intron_inclusion | no | high | Cell Ranger v3.1 default counts exons only. The --include-introns flag was not available until Cell Ranger v7.0. No mention of custom GTF or intron counting in methods. Upgraded from medium to high confidence based on Cell Ranger version constraint. |
| ambient_count_correction | none | high | No mention of SoupX, CellBender, DecontX, or any ambient RNA correction in main methods, PMC full text (PMC10655552), supplementary materials, or GEO (GSE174588). The only "ambient" mention in the paper refers to mouse housing temperature. Code availability states "No specific code was developed in this study." No GitHub or Zenodo deposits exist. |
| doublet_detection | none | high | No computational doublet detection (Scrublet, DoubletFinder, scDblFinder) used. Doublets were excluded pre-sequencing via FACS singlet gating: "we excluded doublets, dead cells (SytoxBlue+), lin+ (CD31+/CD45+)." Extended Data Fig. 1a shows the FACS singlets gate. No post-sequencing computational doublet removal mentioned in main methods, PMC full text, supplementary materials, or GEO page. No GitHub or Zenodo code deposits exist for this study. |
| batch_conditions | not explicitly stated | medium | No "batch" keyword appears in the paper. Each sample was generated as an individual scRNA-seq library. Seurat integration was used across patients: "integration anchors were identified across all individual patient library samples." Likely per-sample (donor_id) but not explicitly labeled as batch variable. |
| description | Single-cell RNA sequencing of preneoplastic BRCA1-mutant and noncarrier human breast tissues, profiling epithelial and stromal cell populations to characterize the premalignant stromal niche in BRCA1-mediated breast tumorigenesis. | high | Derived from abstract and title. |
| publication_doi | 10.1038/s41588-023-01298-x | high | Nature Genetics 2023, vol 55, pp 595-606. PMID: 36914836. PMCID: PMC10655552. |

## Additional Metadata

- **GEO accession**: GSE174588
- **PMCID**: PMC10655552
- **PMID**: 36914836
- **Analysis software**: Seurat v4.0.4, R v4.1.0
- **QC filters**: 200-6000 genes/cell, <20% mitochondrial genes, >=80% viability (SytoxBlue FACS)
- **Chemistry breakdown**: 10x 3' v1 (2 samples: noncarrier 1, BRCA1+/mut 1; User Guide CG00026 Rev B), 10x 3' v2 (20 samples: noncarrier 2-11, BRCA1+/mut 2-11; User Guide CG00052 Rev B)
- **GEO library count discrepancy**: GEO Overall Design states "four 10x genomics v1 chemistry, and twenty-four 10x genomics v2 chemistry" (28 total), but only 22 GEO samples exist. The difference likely reflects separate epithelial/stromal sorted fractions per patient for some libraries that were combined in GEO sample records.
- **GEO platform discrepancy**: GEO lists only GPL24676 (Illumina NovaSeq 6000); paper states both HiSeq4000 and NovaSeq6000.
- **Total cells**: 230,100 (per Methods)
- **Samples**: n=22 (11 noncarrier + 11 BRCA1+/mut)
- **Cell sorting**: FACS isolation of epithelial (Lin-/EpCAM+) and stromal (Lin-/EpCAM-) cells
- **Code availability**: "No specific code was developed in this study and all data was processed and analyzed using existing software packages and tools as described in Methods"
- **Supplementary materials**: Supplementary Fig 1 (western blots), Reporting Summary, Peer Review File, Supplementary Tables 1-17 (XLSX), Supplementary Data (modeling figure .ai). No supplementary methods text beyond what is in the main Methods section.

## Source

Nee K et al., "Preneoplastic stromal cells promote BRCA1-mediated breast tumorigenesis." Nature Genetics 55, 595-606 (2023).
https://www.nature.com/articles/s41588-023-01298-x

Sources checked: Main paper Methods (Nature Genetics, all subsections), PMC full text (PMC10655552), GEO page (GSE174588), Extended Data Fig. 1 (FACS gating strategy), Supplementary Information PDF (western blots only), Reporting Summary PDF, PubMed record (PMID 36914836), EBI OLS (EFO term verification). No GitHub or Zenodo deposits exist ("No specific code was developed in this study").
