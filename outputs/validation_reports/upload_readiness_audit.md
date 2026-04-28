# Upload Readiness Audit — iHBCAv1

**Date**: 2026-03-02
**Object**: all-breast-cells.h5ad (2,122,065 cells, 287 donors, 7 studies)
**Scope**: Five independent workstreams assessing data quality and completeness beyond category (a) validation compliance.
**Status**: Audit-only — all fixes gated on coordinator review.

---

## Executive Summary

| Workstream | Scope | Blockers | Warnings | Advisory |
|------------|-------|----------|----------|----------|
| A: CL Unknown Cells | 70,209 cells (3.3%) | 0 | 0 | 1 |
| B: Donor ID Crosswalk | Reed (55), Pal (22), Nee (22) | 1 | 0 | 0 |
| C: DOI/GEO Accessions | 7 studies | 0 | 0 | 0 |
| D: Murrow Gene Residual | 1,470 unmapped genes | 0 | 0 | 1 |
| E: Category (b) Assessment | B1-B5 validation items | 3 | 1 | 1 |
| **Total** | | **4** | **1** | **3** |

### Open Decisions

1. **HANCESTRO:0612** (Hispanic or Latin American) — CxG hard fail. Remap to accepted term. (E/B2)
2. **HANCESTRO:0847** (unknown identity) — CxG hard fail. Replace with `"unknown"` string. (E/B3)
3. **HsapDv:0000087** (adult, human stage) — deprecated. Replace with HsapDv:0000258. (E/B4)
4. **Nee donor_id whitespace** — 11/22 Nee donors have leading spaces in L1_harmonized_donor.csv, causing key mismatch during integrated assembly. (B/B1)

### Meta-Finding

**HCA validator never ran successfully.** All 11 `*_hca.log` files contain only a module import error. The claim of "11/11 PASS" from the validation_fixes session is not substantiated by any log evidence. CxG was run with `--ignore-labels`, which may mask label-related failures.

---

## A: CL Unknown Cells

### Findings

- **Count verified**: 70,209 cells with `cell_type_ontology_term_id == "unknown"` (3.31% of 2,122,065)
- **22 distinct `level1.5_annotation` labels** present among unknown cells
- **~82% mappable** to CL terms via the existing annotation→CL crosswalk

### Study Breakdown

| Study | Total Cells | Unknown CL | % Unknown |
|-------|-------------|------------|-----------|
| Reed | 803,283 | 27,673 | 3.4% |
| Kumar | 714,331 | 14,466 | 2.0% |
| Twigger | 110,744 | 9,311 | 8.4% |
| Pal | 124,790 | 6,584 | 5.3% |
| Nee | 230,100 | 6,249 | 2.7% |
| Murrow | 86,136 | 4,328 | 5.0% |
| Gray | 52,681 | 1,598 | 3.0% |

### Top Annotation Labels (Unknown Cells)

| level1.5_annotation | Count | % of Unknown | Mappable |
|---------------------|-------|-------------|----------|
| Luminal adaptive secretory precursor | 13,981 | 19.9% | Yes (CL:4033057) |
| Luminal hormone sensing | 13,413 | 19.1% | Yes (CL:4033058) |
| Fibroblast | 11,243 | 16.0% | Yes (CL:0002555) |
| Doublet | 7,266 | 10.3% | No (exclude) |
| Single nuclei | 5,394 | 7.7% | No (exclude) |
| Vascular endothelial | 5,343 | 7.6% | Yes (CL:0002543) |
| Lactocyte | 4,944 | 7.0% | Yes (CL:0000704) |
| Perivascular | 2,523 | 3.6% | Yes (CL:4033054) |
| Basal-myoepithelial | 2,508 | 3.6% | Yes (CL:0002324) |
| CD8T | 1,366 | 1.9% | Yes (CL:0000909) |
| (12 more labels) | 2,228 | 3.2% | Yes |

### Hierarchy

The 572 unique `level1.5_annotation` × `cell_type_ontology_term_id` combinations form the complete crosswalk. Unknown cells are exclusively from the 4 non-CxG studies (kumar, murrow, nee, pal) where CL terms were not available at assembly time.

### Classification

**ADVISORY**: The existing `level1.5_annotation` → CL mapping from the integrated object provides a ready-made crosswalk for CL backfill. The `cl_term_backfill` plan (complete) built per-study crosswalk CSVs for this purpose. Doublet (7,266) and Single nuclei (5,394) cells should remain `unknown` — they are not valid cell types.

### Fix Proposal

Apply existing `cl_term_crosswalk_{murrow,nee,pal}.csv` mappings during `assemble_h5ad.py` assembly. Kumar unknown cells map through the integrated crosswalk table (572 combinations). Requires reassembly of 4 source h5ads + integrated object.

---

## B: Donor ID Crosswalk

### Findings

287 total donors across 7 studies. 3 studies have donor_id alignment issues:

| Study | L1 Donors | Matched | Unmatched | Root Cause |
|-------|-----------|---------|-----------|------------|
| Gray | 16 | 16 | 0 | — |
| Kumar | 126 | 126 | 0 | — |
| Murrow | 28 | 28 | 0 | — |
| Twigger | 18 | 18 | 0 | — |
| **Nee** | **22** | **11** | **11** | Whitespace bug |
| **Pal** | **22** | **0** | **22** | Naming convention mismatch |
| **Reed** | **55** | **0** | **55** | CxG anonymized IDs |

### B1-Nee: Whitespace Bug (BLOCKER)

**Root cause**: L1_harmonized_donor.csv contains leading spaces on 11 Ctrl-group Nee donor IDs:

```
" Ctrl_ Pt1"  through  " Ctrl_ Pt9"   (leading space)
"BRCA1_ Pt1"  through  "BRCA1_Pt11"   (no leading space)
```

`assemble_integrated.py:549-550` constructs keys as `{Study.capitalize()}_{ihbca_donor_id}` with no `.strip()`, so the 11 Ctrl donors fail to match because `Nee_ Ctrl_ Pt1` != `Nee_Ctrl_ Pt1`.

The split is exactly 11 BRCA1 (match) / 11 Ctrl (fail), confirming the whitespace hypothesis.

**Fix**: Either strip whitespace in L1_harmonized_donor.csv source, or add `.strip()` to the key construction in `assemble_integrated.py`. Both are equivalent — recommend fixing at source (L1 CSV) for correctness.

### B1-Reed: CxG Anonymized IDs

**Root cause**: Reed's integrated donor_ids are `HBCA_Donor_1` through `HBCA_Donor_55` — anonymous CxG identifiers from the original CELLxGENE deposit. L1_harmonized_donor.csv uses tissue bank IDs (`Reed_1016CP`, `Reed_2973CP`, etc.).

No bridge mapping exists in the repo between `HBCA_Donor_N` and tissue bank IDs.

The `cell_id_mapping.csv` for Reed (803,283 rows) connects ihbca_cell_ids to HBCA_Donor_N but does not contain tissue bank IDs.

**Fix**: Requires an external donor-ID mapping from the source study authors. The tissue bank IDs (format: `{4-digit}CP|PM|N`) are from the Wellcome Sanger tissue collection. Until this mapping is obtained, the 55 Reed donors cannot be enriched with L1 metadata (ethnicity, age, BMI, etc.).

### B1-Pal: Naming Convention Mismatch

**Root cause**: Pal's integrated donor_ids use a different naming convention than L1:

| Integrated (h5ad) | L1 CSV Key |
|-------------------|------------|
| `Pal_PM0372` | `Pal_N_0372` |
| `Pal_PM0095` | `Pal_N_0093` (!) |
| `Pal_MH0023_p123` | `Pal_B1_0023` |
| `Pal_N1105` | `Pal_N_1105` |

The h5ad uses the Pal lab's internal IDs (PM/MH/N prefix from cell_id_mapping). L1 uses `{cohort}_{numeric_id}` format (N_ for normal, B1_ for BRCA1). The mapping is buildable from cell_id_mapping files but requires a translation table.

**Fix**: Build crosswalk from cell_id_mapping `ihbca_cell_id` → `donor_id` (h5ad) → L1 key. Some numeric IDs differ (0093↔0095), requiring careful manual verification of the 22 donors.

---

## C: DOI/GEO Accessions

### Findings

All 7 studies now have DOI and GEO/ArrayExpress accessions staged in config and code:

| Study | DOI | Accession |
|-------|-----|-----------|
| Gray (Dev Cell 2022) | 10.1016/j.devcel.2022.05.003 | GSE180878 |
| Kumar (Nature 2023) | 10.1038/s41586-023-06252-9 | GSE195665 |
| Murrow (Cell Systems 2022) | 10.1016/j.cels.2022.06.005 | GSE198732 |
| Nee (Nat Genet 2023) | 10.1038/s41588-023-01298-x | GSE174588 |
| Twigger (Nat Commun 2022) | 10.1038/s41467-021-27895-0 | E-MTAB-9841 |
| Reed (Nat Genet 2024) | 10.1038/s41588-024-01688-9 | E-MTAB-13664 |
| Pal (EMBO J 2021) | 10.15252/embj.2020107333 | GSE161529 |

### Code Changes Staged

1. **`publication/config/dataset_metadata.yaml`** — `doi` and `geo_accession` fields added to all 7 entries
2. **`publication/scripts/assemble_h5ad.py`** — `doi` and `geo_accession` added to `DATASET_META_FIELDS` (line ~498), will populate `adata.uns` during source assembly
3. **`publication/scripts/assemble_integrated.py`** — `collect_study_accessions()` function added (line ~717), sets `adata.uns["doi"]` and `adata.uns["geo_accession"]` as study-keyed dicts in the integrated object

### Classification

**COMPLETE** — no blockers. Changes take effect on next reassembly.

---

## D: Murrow Gene ID Residual

### Findings

After the GENCODE v24+v32 mapping fix (A12), 1,470 genes remain unmapped (4.5% of 32,738 total murrow genes). This is higher than the ~900 estimate in the session brief.

| Metric | Value |
|--------|-------|
| Total murrow genes | 32,738 |
| Mapped to ENSG | 31,268 (95.5%) |
| Unmapped (symbols) | 1,470 (4.5%) |
| Overlap with integrated gene space | 0 |
| Overlap with HVGs | 0 |

### Mapping Progression

| Stage | Coverage |
|-------|----------|
| Original (v32 + HGNC only) | 66.9% |
| After v24 GTF addition | 95.0% |
| After v24+v32+HGNC merge | 95.5% |

### Gene Categories

**~95% clone-based lncRNA/pseudogene identifiers** — e.g., `RP5-857K21.1`, `RP11-206L10.3`, `AL669831.1`. These are GENCODE v24 clone-based names retired by Ensembl in release 104 (March 2021). The underlying ENSG IDs remain valid but aren't in the current mapping table because `build_gtf_gene_mapping.py` extracts only gene-level entries from the GTF (58,684 unique names vs 60,554 total genes — gap from duplicate name→ENSG mappings).

**~5% other edge cases** — versioned duplicates, renamed/merged genes, integration artifacts.

### Impact

- CxG and HCA validators **accept mixed ENSG/symbol format** — murrow passes validation as-is
- **Zero overlap** with the integrated object's 15,153-gene space
- **Zero overlap** with the 4,991 HVGs
- No impact on cell type classification, integration quality, or differential expression

### Classification

**ADVISORY**: Accept 95.5% for v1.0. Recovery possible via GENCODE v24 GFF3 or Ensembl BioMart (archive release 87) but yields only non-coding features with zero expression signal in the atlas. Estimated effort: ~2 hours if desired for future version.

### Full Audit

Detailed categorization, recoverability analysis, and data sources: `knowledge/audits/murrow_unmapped_genes_audit_20260301.md`

---

## E: Category (b) Assessment

### Context

The validation_summary.md (2026-02-26) documents 5 category (b) items. This workstream classifies each as blocker/warning/advisory for HCA Data Portal submission.

### Log Provenance

- **HCA logs**: All 11 `*_hca.log` files contain only `ModuleNotFoundError: No module named 'hca_schema_validator'` — the HCA validator never executed successfully.
- **CxG logs**: Run with `--ignore-labels` flag, which skips CL term label validation.
- **CAP logs**: Valid results. 4 integrated objects PASS; source datasets mixed.
- **Post-fix run**: No evidence of a post-fix validation run. The "11/11 CxG PASS" claim from the validation_fixes session cannot be verified from available logs.

### Item Classification

#### B1: HANCESTRO Ancestry Branch Terms — WARNING

**Error**: HANCESTRO ancestry-branch terms (:0005 European, :0006 South Asian, etc.) rejected by HCA validator.

**Analysis**: CxG schema 5.3.2 accepts HANCESTRO :0004 (ancestry) descendants. HCA requires :0601 (ethnicity) or :0602 (geography) descendants. CxG-passthrough studies (gray, twigger, reed) inherited ancestry-branch terms from their original CxG deposits.

**Impact**: CxG passes. HCA would fail — but HCA validator never ran to confirm. Since the HCA Data Portal Tracker runs both validators server-side, this needs resolution before upload.

**Fix proposal**: Map ancestry-branch HANCESTRO terms to their ethnicity-branch equivalents (e.g., :0005 European → closest ethnicity descendant). Requires curator decision on which ethnicity terms to use.

#### B2: HANCESTRO:0612 (Hispanic or Latin American) — BLOCKER

**Error**: CxG schema 5.3.2 explicitly forbids this term.

**Affected**: kumar2023, nee2023, all 4 integrated objects.

**Analysis**: This is a CxG hard fail — the term was removed from the CxG allowed list. The validation_summary.md (2026-02-26) lists this as CxG FAIL. No post-fix logs show it resolved. The term needs replacement with an accepted HANCESTRO term.

**Fix proposal**: Remap to `HANCESTRO:0014` (Hispanic or Latin American) or the current accepted equivalent. Requires OLS lookup to confirm which specific HANCESTRO ID CxG 5.3.2 accepts for this population.

#### B3: HANCESTRO:0847 (Unknown Identity) — BLOCKER

**Error**: CxG schema 5.3.2 explicitly forbids this term.

**Affected**: kumar2023, reed2024, all 4 integrated objects.

**Analysis**: Term not in CxG allowed list. Inherited from original CxG deposits (passthrough). CxG hard fail confirmed in 2026-02-26 validation logs.

**Fix proposal**: Replace with the string `"unknown"` which CxG accepts for missing ethnicity data. Alternatively, check if CxG allows `HANCESTRO:0598` (ancestry category: unknown) or similar.

#### B4: HsapDv:0000087 (Adult, Human Stage) — BLOCKER

**Error**: Deprecated developmental stage term.

**Affected**: murrow2022, nee2023, pal2021 (non-CxG assembly path hardcodes this term).

**Analysis**: HsapDv:0000087 was deprecated in the Human Developmental Stages ontology. The replacement is **HsapDv:0000258** (human adult stage). CxG-passthrough studies (gray, twigger, reed) may already use the correct term. The non-CxG assembly path in `assemble_h5ad.py` hardcodes `:0000087`.

**Fix proposal**: Update `assemble_h5ad.py` to use `HsapDv:0000258`. Verify CxG-passthrough studies have correct term. Reassemble affected h5ads.

#### B5: 16 Missing HCA Tier 2+ Columns — ADVISORY

**Error**: HCA validator expects 16 additional obs columns beyond CxG Tier 1 (sample_id, library_id, institute, etc.).

**Analysis**: HCA Atlas Ingestion Process Outline specifies source datasets must be "Tier 1 compliant." Tier 2+ columns are not listed as requirements for initial submission. The 16 columns represent enrichment metadata that can be added post-submission or during the ingest review.

**Impact**: Not a submission blocker. May be requested during HCA review as "nice to have."

### New Finding: tissue_type Column

**Discovery**: The `tissue_type` column (expected value: `"tissue"`) is not set in any h5ad. This is a CxG schema 5.3.2 required field.

**Classification**: **BLOCKER** — add `adata.obs["tissue_type"] = "tissue"` to both assembly scripts.

---

## Consolidated Action Items

### Blockers (Must Fix Before Upload)

| # | Item | Workstream | Fix | Scope |
|---|------|------------|-----|-------|
| 1 | HANCESTRO:0612 forbidden | E/B2 | Remap to accepted term | kumar, nee, 4 integrated |
| 2 | HANCESTRO:0847 forbidden | E/B3 | Replace with `"unknown"` | kumar, reed, 4 integrated |
| 3 | HsapDv:0000087 deprecated | E/B4 | Replace with HsapDv:0000258 | murrow, nee, pal |
| 4 | Nee whitespace in L1 CSV | B/B1 | Strip leading spaces in L1 CSV or add `.strip()` | nee donors in integrated |
| 5 | tissue_type missing | E/new | Add `"tissue"` to obs | all 11 h5ads |
| 6 | HCA validator never ran | E/meta | Fix invocation, run successfully | all 11 h5ads |

### Warnings (Should Fix, Not Blocking CxG)

| # | Item | Workstream | Fix | Scope |
|---|------|------------|-----|-------|
| 7 | HANCESTRO ancestry branch | E/B1 | Map to ethnicity branch equivalents | gray, twigger, reed, integrated |

### Advisory (Track, No Immediate Action)

| # | Item | Workstream | Notes |
|---|------|------------|-------|
| 8 | 70,209 unknown CL cells | A | Backfill ready via cl_term_crosswalk CSVs; Doublet/Single nuclei remain unknown |
| 9 | Murrow 1,470 unmapped genes | D | 95.5% coverage; zero impact on atlas; accept for v1.0 |
| 10 | Tier 2+ HCA columns | E/B5 | Not required for initial submission |
| 11 | Reed 55 donors: no bridge to tissue bank IDs | B/B1 | Requires external mapping from Reed group |
| 12 | Pal 22 donors: naming convention mismatch | B/B1 | Crosswalk buildable from cell_id_mapping; needs manual verification |

---

## Artifacts Produced

| File | Contents |
|------|----------|
| `publication/outputs/validation_reports/upload_readiness_audit_ab.md` | Full HPC A1+B1 audit (1MB, 572 mapping combinations) |
| `publication/scripts/audit_integrated_object.py` | HPC audit script for A1+B1 |
| `publication/run/audit_integrated.sh` | SLURM wrapper for audit script |
| `knowledge/audits/murrow_unmapped_genes_audit_20260301.md` | Full D workstream gene characterization |
| `publication/config/dataset_metadata.yaml` | Updated with DOI/GEO (C workstream) |
| `publication/scripts/assemble_h5ad.py` | Updated with doi/geo_accession fields (C workstream) |
| `publication/scripts/assemble_integrated.py` | Updated with collect_study_accessions() (C workstream) |

## HPC Job

- **Job ID**: 49132910
- **Duration**: ~43 seconds
- **Resources**: 64GB mem, 2 CPUs
- **Log**: `publication/logs/audit_integrated_49132910.out`
