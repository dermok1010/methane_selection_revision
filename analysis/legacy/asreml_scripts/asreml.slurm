#!/bin/bash
#SBATCH --job-name=h_run_thru
#SBATCH --output=h_run_thru.out
#SBATCH --error=h_run_thru.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --time=24:00:00

set -euo pipefail

DIR="$HOME/Dermot_analysis/Phd/Paper_3"
cd "$DIR/genetic_analysis/asreml_scripts/"

# activate license
asreml -z GIAB-EJBD-IDHC-FDAE

# run the ASReml model file
srun asreml h_uni_methane.as






