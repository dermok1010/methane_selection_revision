#!/bin/bash
#SBATCH --job-name=g
#SBATCH --output=g.out
#SBATCH --error=g.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=80G
#SBATCH --time=24:00:00

set -euo pipefail
module load asreml/4.2

DIR="$HOME/Dermot_analysis/Phd/Paper_3"
cd "$DIR/genetic_analysis"

# activate license
asreml -z GIAB-EJBD-IDHC-FDAE

# run the ASReml model file
srun asreml g_uni_ch4.as



