#!/bin/bash
# Self-contained single-model ASReml run for the CH4 x MBW x CO2 trivariate
# (tri_methane_mbw_co2). Submit from INSIDE the extracted job directory:
#   cd tri_methane_mbw_co2 && sbatch run_trivariate.slurm
# Slurm copies this script to a spool dir, so the job finds its files via
# $SLURM_SUBMIT_DIR. Retries via !CONTINUE (restarts from the .rsv) up to 5 times,
# stops at once on "Convergence failed" or a missing .asr, then runs the .pin
# (VPREDICT) pass. Resources sized above the bivariates' 20 GB (three traits,
# 15 variance parameters); revise if the log shows it is still short.
#SBATCH --job-name=tri_ch4_mbw_co2
#SBATCH --output=slurm_logs/%x-%j.out
#SBATCH --error=slurm_logs/%x-%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=48G
#SBATCH --time=72:00:00

set -uo pipefail
cd "${SLURM_SUBMIT_DIR:?SLURM_SUBMIT_DIR not set -- submit with sbatch from inside the job directory}"
mkdir -p slurm_logs
JOB=tri_methane_mbw_co2
command -v asreml >/dev/null 2>&1 || { echo "ERROR: 'asreml' not found on PATH." >&2; exit 1; }
asreml -z "${ASREML_LICENSE_KEY:-GIAB-EJBD-IDHC-FDAE}" || true

for attempt in 1 2 3 4 5; do
  echo "=== $JOB: attempt $attempt/5 ($(date)) ==="
  asreml "$JOB.as"
  if [ ! -s "$JOB.asr" ]; then echo "STOPPING: no $JOB.asr produced -- hard ASReml/workspace error above." >&2; exit 3; fi
  if grep -q "Convergence failed" "$JOB.asr"; then echo "STOPPING: Convergence failed -- needs a model/starting-value change." >&2; exit 2; fi
  if grep -qiE "Parameters Not Converged|LogL not converged" "$JOB.asr" || ! grep -qiE "LogL Converged" "$JOB.asr"; then
    echo "not converged after attempt $attempt; retrying from .rsv"; continue
  fi
  echo "=== $JOB: CONVERGED; running .pin post-processing ==="
  asreml -P"$JOB" "$JOB.pin" || echo "WARNING: .pin processing failed (exit $?)" >&2
  test -s "$JOB.pvc" && echo "=== COMPLETE: $JOB ===" && tail -40 "$JOB.pvc"
  exit 0
done
echo "STOPPING: $JOB did not converge in 5 attempts." >&2
exit 5
