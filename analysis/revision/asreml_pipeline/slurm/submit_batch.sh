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
#   slurm/submit_batch.sh a_uni_methane a_uni_ch4ratio bi_methane_ch4ratio
#                                          # submit only these jobs
#   ASREML_CONCURRENCY=5 slurm/submit_batch.sh
#                                          # override the default throttle (3)
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
for jobname in "${jobnames[@]}"; do
  if [ ! -f "$RUN_DIR/${jobname}/${jobname}.as" ]; then
    echo "  SKIP: $RUN_DIR/${jobname}/${jobname}.as not found" >&2
    continue
  fi
  echo "$jobname" >> "$job_list_file"
done

n_jobs=$(wc -l < "$job_list_file")
if [ "$n_jobs" -eq 0 ]; then
  echo "ERROR: no valid job directories found -- nothing to submit." >&2
  exit 1
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
jobid=$(sbatch --parsable --job-name="asreml_array" \
  --array="1-${n_jobs}%${CONCURRENCY}" \
  --output="$SCRIPT_DIR/slurm_logs/array-%A_%a.out" \
  --error="$SCRIPT_DIR/slurm_logs/array-%A_%a.err" \
  --export="ALL,PIPELINE_ROOT=$PIPELINE_ROOT,JOB_LIST_FILE=$job_list_file" \
  "$SCRIPT_DIR/asreml_job.slurm")

echo "Submitted array job ${jobid} (tasks 1-${n_jobs}, throttled to ${CONCURRENCY} concurrent)."
echo "Track with: squeue -u \$USER -j ${jobid}"
