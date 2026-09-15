# Rebuilt pedigree (2026-09-15)

`01_ped_maker.R` is adapted from `ped_maker.R` (used previously for the
mix99 genomic-evaluation pedigree, in
`sheep-methane-genomics-microbiome/mix99_vm_context/scripts/pedigree/`) --
algorithm unchanged, only phenotype/master-pedigree/output paths differ.
See the script's own header for detail.

## Inputs

- Phenotype file (defines the animal set to build ancestry for):
  `~/PAC_data_pipeline/data/PAC_data_covariates_QC_NA_with_traits_plus_dam_parity.csv`
  (8,185 unique animals) -- the canonical, verified PAC pipeline output
  (see this repo's `docs/manuscript_context.md`).
- Master pedigree: `sheep-methane-genomics-microbiome/mix99_vm_context/input_data/pedigree/sheeppedweight.sas7bdat`
  (1,230,220 cleaned rows after deduplication) -- the same national pedigree
  source used for the mix99 work.

## Result

36,449 animals (phenotyped animals + all available ancestors, expanded to
closure). All structural checks passed cleanly: no duplicate IDs, no
self-parent records, no unresolved sire==dam records, no cycles, fully
topologically sorted (parents before offspring), all 8,185 phenotyped
animals retained. 6 female IDs found entered as sires and 80 male IDs
entered as dams in the raw master pedigree were corrected (that single
invalid parent link dropped, not the whole record) -- this is routine
national-pedigree noise, not a defect in this rebuild.

Parent completeness: 94.7% of phenotyped animals have at least one known
parent, 88.5% have both.

**This is deliberately smaller than the 330,812-animal pedigree used in
the submitted manuscript** (per `docs/asreml_legacy_map.md`, that
number matches the full master-pedigree file being used essentially
unfiltered/unexpanded, rather than an ancestor-closure expansion from
the phenotyped set alone). Per explicit instruction, no attempt was made
to reconcile this against the three legacy pedigree-file versions found
in the ASReml dump -- a new, validated pedigree will replace this file
before the rebuild's results are treated as final. `output_path` in
`01_ped_maker.R` is the only thing that needs to change when that file is
ready.

## Output

`data/pedigree_full_2026-09-15.csv` (gitignored, animal-ID data) --
`techid,sires,dams,sex`, comma-separated, no header, ASReml-ready ordering
(parents before offspring; IDs kept as character strings, `"0"` for
unknown).
