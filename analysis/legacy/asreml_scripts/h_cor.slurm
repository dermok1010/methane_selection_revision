#!/bin/bash
#SBATCH --job-name=correlations
#SBATCH --output=h_cor.out
#SBATCH --error=h_cor.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --time=24:00:00

set -euo pipefail
module load asreml/4.2

DIR="$HOME/Dermot_analysis/Phd/Paper_3"
cd "$DIR/genetic_analysis"

# activate license
asreml -z GIAB-EJBD-IDHC-FDAE

# run the ASReml model file
fail_log="failed_models_$(date +%Y%m%d_%H%M%S).txt"
: > "$fail_log"

for f in h_bi_ch4*.as; do
  echo "=============================="
  echo "Running: $f  ($(date))"
  echo "=============================="

  # run model; if it fails, log it and continue
  srun asreml "$f" || {
    rc=$?
    echo "FAILED (exit $rc): $f  ($(date))" | tee -a "$fail_log"
    continue
  }
done

echo "All done. Failures (if any) in: $fail_log"

