# methane_selection_revision

This repository contains the peer-review revision workflow for the manuscript:

> **"Genetic Parameters and Selection Responses for Alternative Methane Trait
> Definitions in Pasture-Based Sheep"**

It exists to manage the process of responding to reviewer comments, tracing
reported results back to their source analysis, running any additional
diagnostics or revision analyses reviewers require, and producing a revised
manuscript — while keeping the originally submitted manuscript and its
associated analysis clearly separated from new revision work.

The selection-index analysis used for the submitted manuscript (Smith-Hazel
index construction, response-frontier/convex-hull comparison of ratio vs.
residual vs. linear-index methane traits, Monte Carlo uncertainty
propagation) is maintained **separately** in its own repository:

- `dermok1010/Methane_Selection_Index_Analysis`
  (https://github.com/dermok1010/Methane_Selection_Index_Analysis)

That repository is treated as an upstream analysis resource, not vendored or
copied into this one. See `CLAUDE.md` and `docs/manuscript_context.md` for
how it's used and referenced.

## Folder structure

```text
methane_selection_revision/
├── manuscript/
│   ├── submitted/     # The originally submitted manuscript. Immutable baseline -- never edited.
│   │                  # (gitignored -- this repo is public; kept on the VM only, see docs/manuscript_context.md
│   │                  #  for a traceable written summary instead)
│   └── revised/       # Revised manuscript versions produced during this revision.
├── reviews/            # Reviewer comments / editor letters, as received. (gitignored, same reason)
├── analysis/
│   ├── legacy/         # Analysis code/material carried over from the original submission.
│   ├── diagnostics/    # Checks that trace manuscript results back to source, audit legacy code.
│   └── revision/       # New analyses performed specifically to address reviewer comments.
├── results/            # Result outputs (tables, figures, summaries) from revision-stage work.
├── supplementary/       # Supplementary material (submitted and/or revised).
├── response/            # The response-to-reviewers document and related material.
├── docs/                # Project documentation, including docs/manuscript_context.md.
├── scripts/              # Utility scripts supporting the revision workflow.
├── CLAUDE.md
└── README.md
```

## Status

Initial setup stage: repository structure, project documentation, and deep
technical understanding of the submitted manuscript. Reviewer comments and
legacy analysis code have not yet been introduced.
