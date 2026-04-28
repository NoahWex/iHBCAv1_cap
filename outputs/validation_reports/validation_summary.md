# Validation Summary — iHBCAv1 Upload

**Date**: 2026-02-26
**Session**: validation_run
**Jobs**: 48888052 (initial), 48888996 (follow-up v1), 48890247 (follow-up v2)

## Scope

3 validators (CxG schema 5.3.2, CAP >=1.5.1, HCA schema 0.5.0) run on 11 h5ads:
- 7 source datasets: gray2022, kumar2023, murrow2022, nee2023, twigger2022, reed2024, pal2021
- 4 integrated objects: all-breast-cells, breast-epithelial-lineage, breast-stromal-lineage, breast-immune-lineage

**Note**: Only 9 objects are in upload scope (7 source + all-breast-cells + sketch).
Lineage splits were validated but are not uploaded (C1 decision 2026-02-20).

CxG run with `--ignore-labels` (skips CL term label checks during dev).

## Result Matrix

### CxG Validator

| File | Result | Errors |
|------|--------|--------|
| gray2022 | FAIL | retired Ensembl ID (ENSG00000310560), missing feature_is_filtered |
| kumar2023 | FAIL | retired Ensembl ID (ENSG00000310560), missing feature_is_filtered, HANCESTRO:0612 + :0847 forbidden |
| twigger2022 | FAIL | missing feature_is_filtered |
| reed2024 | FAIL | retired Ensembl IDs (ENSG00000310560, ENSG00000293546), missing feature_is_filtered, HANCESTRO:0847 forbidden |
| murrow2022 | STALE | re-assembled by cl_term_backfill; CxG re-run failed (no __main__.py) |
| nee2023 | STALE | same |
| pal2021 | STALE | same |
| all-breast-cells | FAIL | HANCESTRO:0612 + :0847 forbidden |
| breast-epithelial-lineage | FAIL | HANCESTRO:0612 + :0847 forbidden |
| breast-stromal-lineage | FAIL | HANCESTRO:0612 + :0847 forbidden |
| breast-immune-lineage | FAIL | HANCESTRO:0612 + :0847 forbidden |

### CAP Validator

| File | Result | Error |
|------|--------|-------|
| gray2022 | FAIL | MissingCountMatrix (raw.X or .X) |
| kumar2023 | PASS | — |
| twigger2022 | FAIL | MissingCountMatrix (raw.X or .X) |
| reed2024 | PASS | — |
| murrow2022 | FAIL | NonStandardVar (gene symbols, not Ensembl) |
| nee2023 | FAIL | NonStandardVar (gene symbols, not Ensembl) |
| pal2021 | FAIL | NonStandardVar (gene symbols, not Ensembl) |
| all-breast-cells | PASS | — |
| breast-epithelial-lineage | PASS | — |
| breast-stromal-lineage | PASS | — |
| breast-immune-lineage | PASS | — |

### HCA Validator

All 11 files FAIL. Errors are systemic — 285 total instances collapse to 8 distinct categories (see below).

## Error Categories

### Category (a) — Fixable in assembly scripts

| # | Error | Files | Fix Location |
|---|-------|-------|-------------|
| A1 | `feature_is_filtered` column missing in var | gray, kumar, twigger, reed (CxG + HCA) | `assemble_h5ad.py` — add `adata.var["feature_is_filtered"] = False` |
| A2 | Retired Ensembl IDs: ENSG00000310560, ENSG00000293546 | gray, kumar, reed | `publication/mappings/gene_symbol_to_ensembl_full.tsv` — remove or remap |
| A3 | Reserved obs column names: cell_type, assay, disease, sex, tissue, self_reported_ethnicity, development_stage | 8-9 source + integrated | `assemble_h5ad.py` / `assemble_integrated.py` — rename to `*_label` suffix |
| A4 | Reserved obs column: observation_joinid | 8 files (CxG passthrough) | `assemble_h5ad.py` — drop column |
| A5 | Reserved uns keys: schema_version, schema_reference, citation | all 11 (schema_version); 4 integrated (others) | `assemble_h5ad.py` / `assemble_integrated.py` — drop keys |
| A6 | Reserved var/raw.var columns: feature_type, feature_reference, feature_name, feature_length, feature_biotype | 4 integrated | `assemble_integrated.py` — rename with suffix |
| A7 | `study_pi` in uns is string, must be list | 5 source files; missing in 4 integrated | `assemble_h5ad.py` — wrap in list; `assemble_integrated.py` — add field |
| A8 | Raw count matrix missing from raw.X | gray, twigger | `assemble_h5ad.py` — populate `adata.raw` correctly |
| A9 | Multi-ethnicity delimiter: comma instead of ` \|\| ` | kumar, reed, integrated | `assemble_h5ad.py` / `assemble_integrated.py` — replace `,` with ` \|\| ` |
| A10 | Deprecated `ethnicity` column in obs | 1 file | `assemble_h5ad.py` — drop column |
| A11 | `sample_source` / `sample_preservation_method` invalid enum values | nee | `assemble_h5ad.py` — map to HCA-allowed values |
| A12 | Gene symbols in var index instead of Ensembl IDs | murrow, nee, pal | `assemble_h5ad.py` — non-CxG assembly path needs Ensembl conversion in var index |

### Category (b) — Blocked on other plans or decisions

| # | Error | Files | Blocked On |
|---|-------|-------|-----------|
| B1 | HANCESTRO ancestry-branch terms rejected by HCA (:0005 European, :0006 South Asian, :0007 SE Asian, :0008 Asian, :0016 African American) | 5+ files | CxG uses ancestry branch (:0004); HCA requires ethnicity (:0601) or geography (:0602) descendants. CxG-passthrough studies already have these terms from original deposits. Systematic branch mismatch — requires a remapping-strategy decision. |
| B2 | HANCESTRO:0612 (Hispanic or Latin American) forbidden by CxG 5.3.2 | kumar, nee, all 4 integrated | Validation runbook says "ignore if valid HANCESTRO term." Requires a decision on whether to substitute or request a CxG schema exception. |
| B3 | HANCESTRO:0847 (unknown identity) forbidden by CxG 5.3.2 | kumar, reed, all 4 integrated | Passthrough from original CxG deposits. Term not in our mapping. Requires OLS lookup and a remapping decision. |
| B4 | HsapDv:0000087 deprecated development stage | murrow, nee, pal | Needs replacement term lookup in HsapDv ontology. |
| B5 | 16 missing HCA Tier 2+ obs columns (sample_id, library_id, institute, etc.) | all 11 | Blocked on HCA metadata enrichment — these fields are beyond CxG Tier 1. Requires new plan or extension of dataset_metadata. |

### Category (c) — Genuinely missing data

| # | Gap | Scope |
|---|-----|-------|
| C1 | Ethnicity unknown for ~37% of donors (106/287) | Murrow, Twigger, Pal donors — requires author outreach |

## CxG vs HCA Schema Divergence

The HCA validator (0.5.0) is significantly stricter than CxG (5.3.2):

1. **HANCESTRO**: CxG accepts ancestry-branch terms (:0004 descendants); HCA requires ethnicity (:0601) or geography (:0602) descendants only
2. **Reserved columns**: HCA reserves label columns (cell_type, assay, etc.) that CxG deposits routinely include
3. **Tier 2+ fields**: HCA requires 16 additional obs columns beyond CxG Tier 1
4. **Multi-value delimiter**: HCA requires ` || `; CxG uses comma-separated

This divergence means CxG-passing files will not pass HCA without additional transformation.

## Validator Invocation Notes

- `cellxgene-schema` CLI has stale shebang in conda env (`/dfs6/` vs `/dfs6b/`); `python3 -m cellxgene_schema` also lacks `__main__.py`. Must invoke via `python3 -c "from cellxgene_schema import validate; ..."` or fix the shebang.
- `hca-schema-validator` has no CLI entry point; requires Python wrapper (`publication/scripts/run_hca_validator.py`) calling `HCAValidator().validate_adata(path)`.
- CAP validator works via `python3 -m cap_upload_validator`.

## Files

- Per-file per-validator logs: `publication/outputs/validation_reports/{basename}_{cxg,cap,hca}.log`
- SLURM logs: `publication/logs/validate_all_48888052.out`, `validate_followup_48890247.out`
- HCA wrapper: `publication/scripts/run_hca_validator.py`
- Validation scripts: `publication/run/validate_all.sh`, `publication/run/validate_followup.sh`
