# Provenance note — `all-breast-cells.h5ad` (integrated object)

## Status

The integrated object's `uns['ihbca_provenance']` records `git_dirty: true` with
the repository's initial-commit hash. Unlike the 7 source datasets — which are
stamped to this pipeline's commit `0454dde` (`git_dirty: false`) after verified
byte-identical reproduction — the integrated object's provenance is left as-is.
This note records why.

## Why it isn't stamped to a clean commit

The integrated object was not produced by a single clean forward build. It was
assembled through a multi-step process that includes a metadata-recovery step:
some cell- and study-level annotations were restored from an interim snapshot of
an earlier object state rather than regenerated from source. Because that step
depends on a point-in-time snapshot, and on assembly code maintained outside the
published pipeline, the object cannot be honestly anchored to a single
reproducible commit.

## What was verified

The **core data reproduces exactly.** Rebuilding the integrated object with the
published pipeline's assembler (`iHBCAv1` @ `0454dde`) from its recorded inputs,
then diffing against the deposited object, matched on:

- shape (2,128,505 cells × 36,788 genes)
- counts matrix `X` (identical non-zero structure, dtype, and format)
- genes (order-identical) and joint embeddings (`X_scvi_100`, `X_umap`)
- donor and ontology fields

The differences were confined to a recovery/finalization layer (the `raw` layer,
presentation metadata such as color palettes, and a few annotation columns) added
by the post-assembly steps, not by the core pipeline.

## Recommendation

Leave the object and its `git_dirty` flag as-is; this note is the accurate
provenance. A fully committed, cleanly reproducible integrated object would be a
separate effort: bring the assembly/annotation code into the published pipeline
and redesign the metadata-recovery step as a forward build.
