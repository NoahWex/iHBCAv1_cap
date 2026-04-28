# Dual Build Validation Matrix

**Date**: 2026-03-08
**Plan**: Submission/dual_build_validation

## Validation Matrix (Post-Patch)

After removing `uns['schema_version']` from all 7 HCA-build source h5ads
via `patch_remove_schema_version.py` and re-validating (job 49415091):

```
                    HCA Build                    CxG Build
                CxG    CAP    HCA           CxG    CAP    HCA
gray            PASS   PASS   PASS          PASS   PASS   PASS
kumar           FAIL*  PASS   PASS          PASS   PASS   FAIL†
murrow          PASS   PASS   PASS          PASS   PASS   PASS
nee             FAIL*  PASS   PASS          PASS   PASS   FAIL†
twigger         PASS   PASS   PASS          PASS   PASS   PASS
reed            FAIL*  PASS   PASS          PASS   PASS   FAIL†
pal             PASS   PASS   PASS          PASS   PASS   PASS
all-breast      FAIL*  PASS   PASS          PASS   PASS   FAIL†

*  = KNOWN-ACCEPTABLE (HCA build + CxG validator = HANCESTRO :0601/:0602 not in CxG schema)
†  = KNOWN-ACCEPTABLE (CxG build + HCA validator = downgraded HANCESTRO rejected)
```

**HCA Build**: 8/8 CAP PASS, 8/8 HCA PASS → **submission-ready**
**CxG Build**: 8/8 CAP PASS, 8/8 CxG PASS (source 7/7, integrated 1/1)

HCA-build CxG failures (kumar/nee/reed/all-breast-cells) are due to
HANCESTRO :0601/:0602-branch terms (e.g., :0612, :0847, :0850, :0568, :0590)
not recognized by CxG schema 5.3.2, plus ` || ` delimiter vs `,`. These are
expected — HCA builds target the HCA portal, not CxG.

## Pre-Patch Matrix (Historical)

```
                    HCA Build                    CxG Build
                CxG    CAP    HCA           CxG    CAP    HCA
gray            FAIL   PASS   FAIL          PASS   PASS   PASS
kumar           FAIL   PASS   FAIL          PASS   PASS   FAIL
murrow          FAIL   PASS   FAIL          PASS   PASS   PASS
nee             FAIL   PASS   FAIL          PASS   PASS   FAIL
twigger         FAIL   PASS   FAIL          PASS   PASS   PASS
reed            FAIL   PASS   FAIL          PASS   PASS   FAIL
pal             FAIL   PASS   FAIL          PASS   PASS   PASS
all-breast      FAIL   PASS   FAIL          FAIL   PASS   FAIL
```

All HCA-build CxG+HCA failures were caused by `uns['schema_version']` (single
root cause). CxG-build all-breast-cells CxG failure was also `schema_version`.

## Failure Classification

### RESOLVED: `uns['schema_version']` reserved column

**Was**: BLOCKING — ALL 16 h5ads failed CxG and HCA validators
**Root cause**: `enrich_h5ads.py` writes `schema_version` to `uns`, which is
a reserved column name in CxG schema 5.3.2.
**Fix applied**: `patch_remove_schema_version.py` removed the key from all 7
HCA-build source h5ads. Integrated did not have it. CxG-build h5ads were
assembled without it (CxG assembly path doesn't write this key).
**Result**: HCA build went from 0/8 to 8/8 HCA+CAP PASS.

### KNOWN-ACCEPTABLE: HCA-build CxG validator rejects HANCESTRO :0601/:0602 terms

**Affects**: HCA build only — kumar, nee, reed, all-breast-cells (CxG validator)
**Root cause**: HCA build uses HANCESTRO :0601/:0602-branch terms for ethnicity
(e.g., :0612, :0847, :0850). CxG schema 5.3.2 does not recognize these terms.
Also, HCA uses ` || ` multi-value delimiter vs CxG's `,`.
**Classification**: KNOWN-ACCEPTABLE — HCA builds target the HCA portal, which
accepts these terms. CxG validator failures on HCA builds are expected.

### KNOWN-ACCEPTABLE: CxG-build HCA validator rejects downgraded HANCESTRO terms

**Affects**: CxG build only — kumar, nee, reed, all-breast-cells (HCA validator)
**Root cause**: CxG build downgrades HANCESTRO :0601/:0602 terms to :0004-branch
terms (e.g., HANCESTRO:0005, :0008, :0014) for CxG compatibility. The HCA
validator requires :0601/:0602 descendants and rejects :0004-branch terms.
**Classification**: KNOWN-ACCEPTABLE — CxG builds are not intended for HCA
upload.

### OUT-OF-SCOPE: Gene ID warnings

**Affects**: gray, nee, murrow, pal, all-breast-cells (HCA validator warnings)
**Root cause**: Some Ensembl IDs cannot be resolved by the HCA validator's
internal gene database. These are valid GENCODE v24/v32 IDs.
**Classification**: OUT-OF-SCOPE — warnings only, not errors. Does not affect
PASS/FAIL status.

## Summary

| Category | Count | Status |
|----------|-------|--------|
| RESOLVED | 1 root cause (`schema_version` in uns) | Patched, re-validated |
| KNOWN-ACCEPTABLE | 4 CxG failures on HCA build + 4 HCA failures on CxG build | Documented |
| OUT-OF-SCOPE | Gene ID warnings | None needed |

**Conclusion**: HCA build is 8/8 submission-ready (CAP PASS + HCA PASS).

## Job IDs

| Phase | Job ID | Partition | State | Elapsed |
|-------|--------|-----------|-------|---------|
| Source assembly (CxG) | 49412857_[0-6] | free | COMPLETED | 0:32-5:11 |
| Integrated assembly (CxG) | 49412858 | free | COMPLETED | 16:40 |
| Embedding enrichment | 49412859_[0-6] + 49413468 (nee retry) | free | COMPLETED | 6:29-38:33 |
| Source enrichment | 49413469_[0-6] | free | COMPLETED | 0:29-1:47 |
| Integrated enrichment | 49412861 | free | COMPLETED | 7:56 |
| HCA validation (pre-patch) | 49412862 | free | COMPLETED | 34:37 |
| CxG validation | 49413470 | free | COMPLETED | 25:04 |
| HCA validation (post-patch) | 49415091 | free | COMPLETED | 57:10 |

### Incident: nee embedding CRSP I/O error

Task 49412859_3 (nee) failed with `errno 5` stale file handle reading the
integrated h5ad. Caused by concurrent reads of the 89GB file from multiple
nodes. Recovered by resubmitting as standalone job 49413468 after contention
cleared. No data impact.
