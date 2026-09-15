#!/bin/bash
# Run a single ASReml job to convergence, retrying via !CONTINUE up to
# MAX_ATTEMPTS times. HPC-only -- do not run this on the VM (no ASReml).
#
# Every generated .as file already has !CONTINUE on its top job-control
# line (see scripts/01_generate_models.R). Per
# ASReml-4.2-Functional-Specification.pdf Section 5.8, !CONTINUE looks
# for a .rsv restart-values file and is a safe no-op if none exists yet
# -- so simply re-invoking `asreml jobname.as` again after a
# not-converged run automatically resumes from where the previous run
# left off, using its own .rsv file. No separate "continuation" job file
# is needed.
#
# Usage: run_one_model.sh <jobname-without-.as> [max_attempts]
# Run from inside run/ (the directory populated by 02_stage_run_dir.R).

set -uo pipefail

JOBNAME="$1"
MAX_ATTEMPTS="${2:-5}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_DIR="$PIPELINE_ROOT/run/state"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${JOBNAME}.status"

if [ ! -f "${JOBNAME}.as" ]; then
  echo "ERROR: ${JOBNAME}.as not found in $(pwd)" >&2
  echo "MISSING_AS_FILE" > "$STATE_FILE"
  exit 1
fi

classify() {
  Rscript "$SCRIPT_DIR/../scripts/lib_classify_convergence.R" "${JOBNAME}.asr" 2>/dev/null | tr -d '[:space:]'
}

attempt=1
status="NOT_STARTED"

while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
  echo "=== ${JOBNAME}: attempt ${attempt}/${MAX_ATTEMPTS} ($(date)) ==="
  asreml "${JOBNAME}.as"
  rc=$?
  status="$(classify)"
  echo "=== ${JOBNAME}: attempt ${attempt} finished, exit=${rc}, status=${status} ==="

  case "$status" in
    CONVERGED)
      # A separate .pin processing pass is required to get the VPREDICT
      # h2/repeatability/correlation results into a .pvc file -- the
      # legacy dump shows this step was run for bivariate jobs but NOT
      # for univariate ones (no a_uni_*.pvc exists anywhere in it), so
      # this is not optional here.
      if [ -f "${JOBNAME}.pin" ]; then
        echo "=== ${JOBNAME}: running .pin post-processing for VPREDICT results ==="
        asreml -P"${JOBNAME}" "${JOBNAME}.pin" || \
          echo "WARNING: ${JOBNAME}.pin processing failed (exit $?) -- .asr Model_Term table is still available." >&2
      fi
      echo "CONVERGED attempt=${attempt}" > "$STATE_FILE"
      exit 0
      ;;
    CONVERGENCE_FAILED)
      # Per the manual this needs a model change, not more iterations --
      # retrying !CONTINUE on the same model is very unlikely to help.
      # Stop immediately and flag rather than burn the remaining budget.
      echo "CONVERGENCE_FAILED attempt=${attempt}" > "$STATE_FILE"
      echo "STOPPING: ${JOBNAME} reported Convergence failed -- needs a model/starting-value change, not more iterations." >&2
      exit 2
      ;;
    MISSING)
      echo "MISSING_ASR attempt=${attempt}" > "$STATE_FILE"
      echo "STOPPING: ${JOBNAME}.asr was not produced -- check for a hard ASReml/workspace error above." >&2
      exit 3
      ;;
    UNKNOWN)
      echo "UNKNOWN attempt=${attempt}" > "$STATE_FILE"
      echo "STOPPING: ${JOBNAME}.asr did not match any known convergence pattern -- inspect by hand." >&2
      exit 4
      ;;
    NOT_CONVERGED|CONVERGED_PARAMS_UNSTABLE)
      # Expected/recoverable -- loop again, !CONTINUE picks up the .rsv.
      ;;
  esac

  attempt=$((attempt + 1))
done

echo "MAX_ATTEMPTS_EXCEEDED attempts=${MAX_ATTEMPTS} last_status=${status}" > "$STATE_FILE"
echo "STOPPING: ${JOBNAME} did not converge after ${MAX_ATTEMPTS} attempts (last status: ${status})." >&2
exit 5
