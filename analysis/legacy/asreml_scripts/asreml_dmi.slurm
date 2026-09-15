#!/bin/bash
#SBATCH --job-name=Tri
#SBATCH --output=T_tri.out
#SBATCH --error=T_tri.err
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
srun asreml tri.as



