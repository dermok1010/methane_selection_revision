#!/bin/bash
# Slurm job template for one ASReml model, submitted once per job via
# submit_batch.sh (`sbatch --job-name=$JOBNAME --export=JOBNAME=$JOBNAME
# asreml_job.slurm`). Resource requests copied from the legacy
# submission scripts (analysis/legacy/asreml_scripts/*.slurm) as a
# starting point -- revisit if the full sweep's bivariate models need
# more time/memory than the legacy single-pair runs did.
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
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --time=24:00:00

set -euo pipefail

if [ -z "${JOBNAME:-}" ]; then
  echo "ERROR: JOBNAME not set -- submit via submit_batch.sh, not sbatch directly." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE_ROOT="$(dirname "$SCRIPT_DIR")"
RUN_DIR="$PIPELINE_ROOT/run"

# asreml/4.2 module load made non-fatal: on this account ASReml is
# reportedly already on PATH (license tied to the user, not a module),
# so don't abort the job if the module genuinely isn't present.
module load asreml/4.2 2>/dev/null || true

if ! command -v asreml >/dev/null 2>&1; then
  echo "ERROR: 'asreml' not found on PATH after attempting 'module load asreml/4.2'." >&2
  echo "Check how ASReml is normally invoked on this account/cluster and update this line." >&2
  exit 1
fi

cd "$RUN_DIR"
mkdir -p "$PIPELINE_ROOT/slurm/slurm_logs"

# Reports license details -- kept for continuity with the legacy
# submission scripts; !CONTINUE etc. do not depend on this line.
asreml -z "${ASREML_LICENSE_KEY:-GIAB-EJBD-IDHC-FDAE}" || true

MAX_ATTEMPTS="${ASREML_MAX_ATTEMPTS:-5}"
"$SCRIPT_DIR/run_one_model.sh" "$JOBNAME" "$MAX_ATTEMPTS"
