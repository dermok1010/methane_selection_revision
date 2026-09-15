#!/bin/bash
# Submit one Slurm job per model directory staged in run/<jobname>/
# (populated by scripts/02_stage_run_dir.R -- each job gets its own
# isolated working directory, see that script's header for why). HPC-only.
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
  for d in "$RUN_DIR"/*/; do
    jobnames+=("$(basename "$d")")
  done
fi

echo "Submitting ${#jobnames[@]} job(s)..."
for jobname in "${jobnames[@]}"; do
  if [ ! -f "$RUN_DIR/${jobname}/${jobname}.as" ]; then
    echo "  SKIP: $RUN_DIR/${jobname}/${jobname}.as not found" >&2
    continue
  fi
  # --output/--error given as absolute paths on the command line: Slurm
  # resolves #SBATCH --output=slurm_logs/... relative to wherever sbatch
  # was INVOKED from, not relative to the .slurm script's own location --
  # a relative path there fails instantly (job can't even start if Slurm
  # can't open the output file) unless submit_batch.sh happens to be run
  # from exactly slurm/. Command-line options override #SBATCH lines, so
  # this makes submission location-independent.
  # PIPELINE_ROOT is passed explicitly because Slurm copies the .slurm
  # script into a spool directory before running it -- the job cannot
  # reliably figure out its own real location from inside itself.
  jobid=$(sbatch --parsable --job-name="$jobname" \
    --output="$SCRIPT_DIR/slurm_logs/%x-%j.out" \
    --error="$SCRIPT_DIR/slurm_logs/%x-%j.err" \
    --export="ALL,JOBNAME=$jobname,PIPELINE_ROOT=$PIPELINE_ROOT" "$SCRIPT_DIR/asreml_job.slurm")
  echo "  submitted ${jobname} as Slurm job ${jobid}"
done
