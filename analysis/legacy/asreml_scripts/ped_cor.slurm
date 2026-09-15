#!/bin/bash
#SBATCH --job-name=correlations
#SBATCH --output=ped_cor.out
#SBATCH --error=ped_cor.err
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
#srun asreml bi_ch4_ch4rmtadg.as
#srun asreml bi_ch4_ch4co2.as
#srun asreml bi_ch4mbw_ch4rmtadg.as
srun asreml bi_ch4mbw_ch4co2.as
#srun asreml bi_ch4mbw_ch4dmi.as
#srun asreml bi_ch4mbw_ch4adg.as
srun asreml bi_ch4dmi_ch4adg.as
#srun asreml bi_ch4dmi_ch4muscle.as
#srun asreml bi_ch4dmi_ch4rumen.as
#srun asreml bi_ch4dmi_ch4rmtadg.as
srun asreml bi_ch4dmi_ch4co2.as
#srun asreml bi_ch4dmi_ch4rmtdmi.as
#srun asreml bi_ch4adg_ch4muscle.as
#srun asreml bi_ch4adg_ch4rumen.as
#srun asreml bi_ch4adg_ch4rmtadg.as
#srun asreml bi_ch4adg_ch4co2.as
srun asreml bi_ch4adg_ch4rmtmbw.as
#srun asreml bi_ch4adg_ch4rmtdmi.as
#srun asreml bi_ch4muscle_ch4rmtrumen.as
srun asreml bi_ch4muscle_ch4ratio.as
#srun asreml bi_ch4muscle_ch4rmtmbw.as
#srun asreml bi_ch4muscle_ch4rmtdmi.as
#srun asreml bi_ch4rumen_ch4rmtadg.as
#srun asreml bi_ch4rumen_ch4rmtdmi.as
srun asreml bi_ch4rumen_ch4co2.as
#srun asreml bi_ch4rumen_ch4rmtmbw.as
#srun asreml bi_ch4rmtadg_ch4co2.as
srun asreml bi_ch4rmtadg_ch4rmtdmi.as
#srun asreml bi_ch4rmtadg_ch4rmtmbw.as
srun asreml bi_ch4co2_ch4rmtdmi.as
srun asreml bi_ch4co2_ch4rmtmbw.as


