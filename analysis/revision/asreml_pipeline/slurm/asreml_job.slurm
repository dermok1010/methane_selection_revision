#!/bin/bash
# Slurm job template for one ASReml model. Normally run as one task of a
# job array submitted by submit_batch.sh (--array=1-N%throttle), which
# resolves JOBNAME from a job-list file per task -- see the JOBNAME
# resolution block below. --mem/--time copied from the legacy submission
# scripts (analysis/legacy/asreml_scripts/*.slurm) as a starting point --
# revisit if the full sweep's bivariate models need more than the legacy
# single-pair runs did. --cpus-per-task deliberately kept low (ASReml is
# reported not to scale well with more threads); must match
# config/models.yaml's mp_threads, which is what actually caps ASReml's
# own thread use via !MP on the generated .as files -- the legacy .as
# files never set !MP, so every legacy job silently used up to its
# default of 16 threads regardless of what Slurm had allocated.
#SBATCH --job-name=asreml_model
# --output/--error left as relative-path fallbacks here, but
# submit_batch.sh always overrides these with absolute paths on the
# sbatch command line -- do not rely on these two lines if submitting
# any other way (a relative path is resolved against wherever `sbatch`
# was invoked from, not this script's location, and fails instantly if
# that directory doesn't exist).
#SBATCH --output=slurm_logs/%x-%j.out
#SBATCH --error=slurm_logs/%x-%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=20G
#SBATCH --time=24:00:00

set -euo pipefail

# Two ways this script gets its JOBNAME, both set up by submit_batch.sh:
#   - array submission (the normal path, --array=1-N%throttle): JOBNAME
#     isn't known until the task starts, so JOB_LIST_FILE + the task's
#     own SLURM_ARRAY_TASK_ID are exported instead, and JOBNAME is
#     resolved here by reading that line of the job list.
#   - single ad-hoc submission (JOBNAME exported directly, no array) --
#     kept working for resubmitting one specific job by hand.
if [ -n "${SLURM_ARRAY_TASK_ID:-}" ]; then
  if [ -z "${JOB_LIST_FILE:-}" ]; then
    echo "ERROR: JOB_LIST_FILE not set for an array task -- submit via submit_batch.sh." >&2
    exit 1
  fi
  JOBNAME="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOB_LIST_FILE")"
  if [ -z "$JOBNAME" ]; then
    echo "ERROR: no jobname found at line ${SLURM_ARRAY_TASK_ID} of ${JOB_LIST_FILE}." >&2
    exit 1
  fi
  echo "Array task ${SLURM_ARRAY_TASK_ID}: JOBNAME=${JOBNAME}"
elif [ -z "${JOBNAME:-}" ]; then
  echo "ERROR: JOBNAME not set -- submit via submit_batch.sh, not sbatch directly." >&2
  exit 1
fi

# PIPELINE_ROOT must be exported by submit_batch.sh (via --export), not
# self-derived from this script's own location: Slurm copies the
# submitted script into a spool directory before running it
# (/cm/local/apps/slurm/var/spool/jobNNNNN/...), so
# dirname "${BASH_SOURCE[0]}" resolves to that spool path, not the real
# repo -- this previously caused every job to fail instantly trying to
# cd into a nonexistent spool-relative "run" directory.
if [ -z "${PIPELINE_ROOT:-}" ]; then
  echo "ERROR: PIPELINE_ROOT not set -- submit via submit_batch.sh, not sbatch directly." >&2
  exit 1
fi
SCRIPT_DIR="$PIPELINE_ROOT/slurm"
# Each job gets its own working directory (run/<jobname>/) -- see
# scripts/02_stage_run_dir.R's header comment for why running multiple
# ASReml jobs concurrently from one shared directory is unsafe.
JOB_DIR="$PIPELINE_ROOT/run/$JOBNAME"

# ASReml is available directly on PATH on this account (license is
# per-user, not a module) -- no module load needed or attempted.
if ! command -v asreml >/dev/null 2>&1; then
  echo "ERROR: 'asreml' not found on PATH." >&2
  exit 1
fi

if [ ! -d "$JOB_DIR" ]; then
  echo "ERROR: $JOB_DIR does not exist -- run scripts/02_stage_run_dir.R --platform=hpc first." >&2
  exit 1
fi
cd "$JOB_DIR"
mkdir -p "$PIPELINE_ROOT/slurm/slurm_logs"

# Reports license details -- kept for continuity with the legacy
# submission scripts; !CONTINUE etc. do not depend on this line.
asreml -z "${ASREML_LICENSE_KEY:-GIAB-EJBD-IDHC-FDAE}" || true

MAX_ATTEMPTS="${ASREML_MAX_ATTEMPTS:-5}"
"$SCRIPT_DIR/run_one_model.sh" "$JOBNAME" "$MAX_ATTEMPTS"
