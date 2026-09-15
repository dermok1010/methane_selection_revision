#!/bin/bash
# Submit every staged job as ONE Slurm job array with a concurrency
# throttle, rather than N independent jobs. HPC-only.
#
# ASReml on this account is licensed for a limited number of concurrent
# sessions (observed: "14 sessions available, with 8 currently in use"
# -- a pool shared with whatever else is running on the account, not
# reserved for this pipeline). Submitting every job independently would
# have most of them competing for license checkouts rather than
# compute. A Slurm array with %N throttling (--array=1-COUNT%N) queues
# everything but only ever runs N at a time, which is the right
# primitive for a shared, capacity-limited resource like this.
#
# Usage:
#   slurm/submit_batch.sh                 # submit every job dir in run/
#                                          # that isn't already CONVERGED
#                                          # (see skip logic below)
#   slurm/submit_batch.sh a_uni_methane a_uni_ch4ratio bi_methane_ch4ratio
#                                          # submit only these jobs
#   ASREML_CONCURRENCY=5 slurm/submit_batch.sh
#                                          # override the default throttle (3)
#   ASREML_MAIL_USER=someone@teagasc.ie slurm/submit_batch.sh
#                                          # override the default notification address
#   ASREML_MAIL_USER= slurm/submit_batch.sh
#                                          # disable email notification entirely
#   ASREML_FORCE_RERUN=1 slurm/submit_batch.sh ...
#                                          # also (re)submit already-CONVERGED jobs
#
# Already-CONVERGED jobs are skipped by default (2026-09-15: run/
# accumulates staged job directories from every --set= ever generated --
# validation, full, components, components_trial all land in the same
# run/ -- so "submit everything in run/" with no arguments previously
# resubmitted an already-completed 55-model sweep alongside 10 new
# component-trial jobs, on a license shared with other work. Checking
# each candidate's .asr via lib_classify_convergence.R before adding it
# to the job list makes the no-argument form safe regardless of what
# else happens to be sitting in run/.
#
# Email notification: --mail-type=END,FAIL without --mail-type=ARRAY_TASKS
# sends ONE email for the whole array (on completion or first failure),
# not one per task -- exactly what you want for a 7-14 task array.
#
# Each array task runs slurm/asreml_job.slurm -> slurm/run_one_model.sh,
# which handles convergence detection and !CONTINUE retries on its own
# -- this script only submits, it does not wait or poll.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE_ROOT="$(dirname "$SCRIPT_DIR")"
RUN_DIR="$PIPELINE_ROOT/run"
STATE_DIR="$RUN_DIR/state"
CONCURRENCY="${ASREML_CONCURRENCY:-3}"
# Assumed domain is teagasc.ie -- correct via ASREML_MAIL_USER if wrong.
MAIL_USER="${ASREML_MAIL_USER-dermot.kelly@teagasc.ie}"

if [ ! -d "$RUN_DIR" ]; then
  echo "ERROR: $RUN_DIR does not exist -- run scripts/02_stage_run_dir.R --platform=hpc first." >&2
  exit 1
fi

mkdir -p "$SCRIPT_DIR/slurm_logs" "$STATE_DIR"

if [ "$#" -gt 0 ]; then
  jobnames=("$@")
else
  jobnames=()
  for d in "$RUN_DIR"/*/; do
    name="$(basename "$d")"
    [ "$name" = "state" ] && continue  # not a job directory -- see config/paths.yaml's state_dir
    jobnames+=("$name")
  done
fi

# Validate and write the job list array tasks index into (1-based, one
# jobname per line -- array task $i reads line $i).
job_list_file="$STATE_DIR/job_list_$(date +%Y%m%d_%H%M%S).txt"
: > "$job_list_file"
FORCE_RERUN="${ASREML_FORCE_RERUN:-0}"
n_skipped_converged=0
for jobname in "${jobnames[@]}"; do
  if [ ! -f "$RUN_DIR/${jobname}/${jobname}.as" ]; then
    echo "  SKIP: $RUN_DIR/${jobname}/${jobname}.as not found" >&2
    continue
  fi
  if [ "$FORCE_RERUN" != "1" ]; then
    status="$(Rscript "$SCRIPT_DIR/../scripts/lib_classify_convergence.R" \
      "$RUN_DIR/${jobname}/${jobname}.asr" 2>/dev/null | tr -d '[:space:]')"
    if [ "$status" = "CONVERGED" ]; then
      echo "  SKIP: $jobname already CONVERGED (set ASREML_FORCE_RERUN=1 to resubmit anyway)" >&2
      n_skipped_converged=$((n_skipped_converged + 1))
      continue
    fi
  fi
  echo "$jobname" >> "$job_list_file"
done

n_jobs=$(wc -l < "$job_list_file")
if [ "$n_jobs" -eq 0 ]; then
  if [ "$n_skipped_converged" -gt 0 ]; then
    echo "Nothing to submit -- all $n_skipped_converged candidate job(s) are already CONVERGED." >&2
    echo "(Set ASREML_FORCE_RERUN=1 to resubmit anyway.)" >&2
  else
    echo "ERROR: no valid job directories found -- nothing to submit." >&2
  fi
  exit 1
fi

if [ "$n_skipped_converged" -gt 0 ]; then
  echo "Skipped $n_skipped_converged already-CONVERGED job(s) -- see SKIP lines above."
fi
echo "Submitting $n_jobs job(s) as one array, max $CONCURRENCY running at once (ASREML_CONCURRENCY)..."
echo "Job list: $job_list_file"

# --output/--error use Slurm's own array tokens (%A = array job id,
# %a = task index) since the jobname isn't known until the task starts
# reading the job list -- the task's own first log line prints the
# resolved jobname so logs stay identifiable by content even though the
# filename is index-based. Absolute paths for the same reason as the
# single-job case: relative #SBATCH paths resolve against wherever
# sbatch was invoked from, not this script's location.
mail_args=()
if [ -n "$MAIL_USER" ]; then
  mail_args=(--mail-user="$MAIL_USER" --mail-type=END,FAIL)
  echo "Email notification: one summary email to $MAIL_USER on array completion/failure."
fi

jobid=$(sbatch --parsable --job-name="asreml_array" \
  --array="1-${n_jobs}%${CONCURRENCY}" \
  --output="$SCRIPT_DIR/slurm_logs/array-%A_%a.out" \
  --error="$SCRIPT_DIR/slurm_logs/array-%A_%a.err" \
  --export="ALL,PIPELINE_ROOT=$PIPELINE_ROOT,JOB_LIST_FILE=$job_list_file" \
  "${mail_args[@]}" \
  "$SCRIPT_DIR/asreml_job.slurm")

echo "Submitted array job ${jobid} (tasks 1-${n_jobs}, throttled to ${CONCURRENCY} concurrent)."
echo "Track with: squeue -u \$USER -j ${jobid}"
