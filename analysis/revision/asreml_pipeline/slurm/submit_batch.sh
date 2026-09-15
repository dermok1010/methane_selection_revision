#!/bin/bash
# Submit one Slurm job per .as file currently staged in run/ (populated
# by scripts/02_stage_run_dir.R). HPC-only.
#
# Usage:
#   slurm/submit_batch.sh                 # submit every *.as in run/
#   slurm/submit_batch.sh a_uni_methane a_uni_ch4ratio bi_methane_ch4ratio
#                                          # submit only these jobs (the
#                                          # trial-batch step of the
#                                          # intended workflow)
#
# Each job runs slurm/asreml_job.slurm -> slurm/run_one_model.sh, which
# handles convergence detection and !CONTINUE retries on its own -- this
# script only submits, it does not wait or poll.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE_ROOT="$(dirname "$SCRIPT_DIR")"
RUN_DIR="$PIPELINE_ROOT/run"

if [ ! -d "$RUN_DIR" ]; then
  echo "ERROR: $RUN_DIR does not exist -- run scripts/02_stage_run_dir.R --platform=hpc first." >&2
  exit 1
fi

mkdir -p "$SCRIPT_DIR/slurm_logs"

if [ "$#" -gt 0 ]; then
  jobnames=("$@")
else
  jobnames=()
  for f in "$RUN_DIR"/*.as; do
    jobnames+=("$(basename "$f" .as)")
  done
fi

echo "Submitting ${#jobnames[@]} job(s)..."
for jobname in "${jobnames[@]}"; do
  if [ ! -f "$RUN_DIR/${jobname}.as" ]; then
    echo "  SKIP: ${jobname}.as not found in $RUN_DIR" >&2
    continue
  fi
  jobid=$(sbatch --parsable --job-name="$jobname" --export="ALL,JOBNAME=$jobname" "$SCRIPT_DIR/asreml_job.slurm")
  echo "  submitted ${jobname} as Slurm job ${jobid}"
done
