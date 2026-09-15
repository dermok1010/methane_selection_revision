# methane_selection_revision

Peer-review revision workflow for the manuscript "Genetic Parameters and
Selection Responses for Alternative Methane Trait Definitions in
Pasture-Based Sheep". This repository manages tracing reported results back
to source analysis, addressing reviewer comments, any additional revision
analyses, and producing a revised manuscript.

See also `~/.claude/CLAUDE.md` for VM-wide conventions (this repo is not yet
listed in that file's project table; add it there if this becomes a
standing project rather than a one-off revision).

## Working principles

- **The submitted manuscript is an immutable baseline.** Everything under
  `manuscript/submitted/` is frozen exactly as received. Never edit, rename,
  or overwrite it. All manuscript revisions go in `manuscript/revised/` as
  new, clearly-versioned files.
- **Never silently alter scientific results.** If a number, figure, or
  claim changes, the change and its justification must be explicit and
  traceable -- not a quiet edit.
- **Distinguish original analysis from revision analysis.** Code/material
  from the original submission belongs in `analysis/legacy/` and should be
  preserved, not destructively rewritten. New analysis performed to address
  reviewer comments belongs in `analysis/revision/`. Work that audits or
  traces legacy results (without changing them) belongs in
  `analysis/diagnostics/`.
- **Maintain reproducibility.** Any analysis added or rerun should be
  runnable from documented inputs to documented outputs. Record software
  versions and random seeds where relevant (this manuscript's selection-index
  work uses Monte Carlo uncertainty propagation, which is seed-sensitive).
- **Document analytical changes.** When a legacy analysis is corrected,
  extended, or reinterpreted, record what changed, why, and what the
  numerical consequence was.
- **Do not invent missing methodological details.** If the manuscript or
  legacy code is ambiguous or silent on a method, say so explicitly rather
  than filling the gap with a plausible-sounding assumption.
- **Trace manuscript values back to source analysis where possible.** Every
  reported number, table, or figure should eventually be traceable to the
  code and data that produced it. Where that trace can't yet be made,
  record it as an open question rather than leaving it implicit.
- **Preserve old code rather than destructively rewriting it.** Legacy
  analysis code is evidence of what actually produced the submitted
  results. Fix forward with new, separately-versioned code rather than
  editing legacy scripts in place, unless explicitly instructed otherwise.
- **Do not modify the upstream selection-index repository**
  (`dermok1010/Methane_Selection_Index_Analysis`) unless explicitly
  instructed. Treat it as a read-only reference. Keep it as a separate
  sibling checkout (`~/Methane_Selection_Index_Analysis`), not copied or
  nested inside this repository's `.git` history.
- **Record commit SHAs when external repositories are used.** Any time the
  upstream selection-index repository (or any other external resource) is
  used to produce or check a result, record the exact commit SHA in use so
  the revision stays reproducible even if that repository changes later.
- **Use version control throughout.** Commit meaningful, documented steps
  rather than large undocumented batches of change.
- **Prioritise scientific correctness over simply satisfying a reviewer.**
  If addressing a reviewer comment surfaces a real problem, fix the
  problem -- don't just produce a response that superficially answers the
  comment.
- **Flag uncertainty explicitly.** Distinguish clearly between what a
  source (manuscript, legacy code, reviewer comment) actually states, what
  is reasonably inferred from it, and what remains genuinely unknown or
  unverified.
- **Distinguish reviewer-driven analyses from original-submission
  analyses.** Never let the two become ambiguous in the repository's
  history or documentation -- a reader should always be able to tell which
  analyses were part of the original submitted study and which were added
  during revision.

## Upstream reference repository

- `dermok1010/Methane_Selection_Index_Analysis`
  (https://github.com/dermok1010/Methane_Selection_Index_Analysis) --
  the selection-index analysis (Smith-Hazel index construction, G/P matrix
  handling, ratio/residual/linear-index trait comparison, response-frontier
  convex-hull analysis, Monte Carlo uncertainty propagation) associated
  with the submitted manuscript. Read-only reference; not vendored into
  this repository. See `docs/manuscript_context.md` for what's currently
  known about its relationship to specific manuscript results, and record
  the commit SHA in use whenever it's consulted analytically.

## Current stage

Repository setup and deep technical reading of the submitted manuscript.
Reviewer comments and legacy analysis code have not yet been introduced;
no new statistical analysis has been performed; no results have been
audited or re-derived yet.
