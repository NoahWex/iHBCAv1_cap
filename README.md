# iHBCA v1.0 — Integrated Human Breast Cell Atlas

This repository holds the code, configuration, and metadata used to assemble, annotate, and validate the integrated Human Breast Cell Atlas (iHBCA) v1.0 — a cross-study single-cell reference of the adult human breast.

**Atlas:** 2,128,505 cells from 287 donors across 7 published single-cell breast studies, integrated with scVI and manually annotated at L1 resolution (11 cell-type groups).

**Submission:** The atlas is packaged and validated for the HCA Cell Annotation Platform (CAP) and the HCA Atlas Tracker.

## What's here

| Directory | Contents |
|---|---|
| `config/` | Source dataset registry, ontology mappings, dataset metadata, donor harmonization stages |
| `scripts/` | Build + validation scripts (assembly, harmonization, packaging, CAP/CxG validation) |
| `run/` | SLURM wrappers for HPC execution |
| `mappings/` | Cell ontology (CL) crosswalks, gene symbol → Ensembl maps, donor ID translations, cohort metadata, EFO assay mappings |
| `outputs/` | Validation reports, audit yamls, per-study entry sheets, UMAP figures, baseline manifests |

## What's not here (lives elsewhere)

- **Source h5ads + integrated `all-breast-cells.h5ad`** — uploaded to HCA Tracker / CAP. Repo references metadata only.
- **Per-cell provenance validation** — 138GB of audit data; auto-generated, not version-controlled.
- **`gencode.v24.annotation.gtf`** — public reference; redownloadable from [GENCODE](https://www.gencodegenes.org/).

## Source studies

| Study | Citation | Cells | Donors |
|---|---|---|---|
| Reed 2024 | Nature Genetics, [10.1038/s41588-024-01688-9](https://doi.org/10.1038/s41588-024-01688-9) | 803,283 | 55 |
| Kumar 2023 | Nature, [10.1038/s41586-023-06252-9](https://doi.org/10.1038/s41586-023-06252-9) | 714,331 | 126 |
| Nee 2023 | Nature Genetics, [10.1038/s41588-023-01298-x](https://doi.org/10.1038/s41588-023-01298-x) | 230,100 | 22 |
| Pal 2021 | EMBO J, [10.15252/embj.2020107333](https://doi.org/10.15252/embj.2020107333) | 131,288 | 22 |
| Twigger 2022 | Nature Communications, [10.1038/s41467-021-27895-0](https://doi.org/10.1038/s41467-021-27895-0) | 110,744 | 16 |
| Murrow 2022 | Cell Systems, [10.1016/j.cels.2022.06.005](https://doi.org/10.1016/j.cels.2022.06.005) | 86,136 | 28 |
| Gray 2022 | Developmental Cell, [10.1016/j.devcel.2022.05.003](https://doi.org/10.1016/j.devcel.2022.05.003) | 52,681 | 16 |

## Cell-type taxonomy (L1, 11 groups)

L1 cell-type annotation comprises 11 groups following the hierarchy of Reed et al. 2024: epithelial (luminal hormone sensing, luminal adaptive secretory precursor, basal-myoepithelial, lactocyte), stromal (fibroblast, vascular endothelial, lymphatic endothelial, perivascular), and immune (B-lymphocyte, T-lymphocyte, myeloid).

Per-label cell counts and CL ontology terms are documented in the CAP metadata template (separate distribution).

## Build provenance

- Source datasets assembled and validated against the CAP, CELLxGENE, and HCA schemas.
- Integrated object: `all-breast-cells.h5ad`.

## License

- Code: MIT
- Data / metadata derived from source studies: as governed by each upstream publication's original license terms

## Contact

Corresponding author: Kai Kessenbrock <kai.kessenbrock@uci.edu>
Kessenbrock Lab, University of California Irvine

Repository maintainer: Noah Wechter <nwechter@uci.edu>
