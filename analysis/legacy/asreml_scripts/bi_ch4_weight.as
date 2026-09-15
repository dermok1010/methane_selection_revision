!WORKSPACE 5000 !CONTINUE !NODISPLAY !LOGFILE !MAXIT 300
bivariate_ch4_vs_weight
 ANI_ID !P
 ch4_g_day2_1v3 1
 co2_g_day2_1v3 1
 ch4_ratio 1
 methane_per_dmi 1
 methane_per_mbw 1
 Metabolic_BW 1
 SEX * !A
 TX 1
 BR 1
 SU 1
 CL 1
 CV 1
 LY 1
 UN 1
 het 1
 rec 1
 age_in_years 1
 ch4_GroupNumber * !A
 weight 1
 DMI 1
 adg 1
 methane_per_adg 1
 methane_per_rumen 1
 methane_per_muscle 1
 rumen 1
 age_in_months 1
 age_in_weeks 1
 REARING_RANK 1
 BIRTH_RANK 1
 ewe_birth_rank 1
 ewe_rearing_rank 1
 dam_parity_group_num 1
 ch4_adj_MBW 1
 ch4_adj_DMI 1
 ch4_adj_adg 1
 
pedigree_full_sas_style.csv.SRT
P3_data.csv !SKIP 1 !MVINCLUDE

ch4_g_day2_1v3 weight ~ Trait Tr.SEX Tr.TX Tr.BR Tr.SU Tr.CL Tr.CV Tr.LY Tr.UN Tr.het Tr.het Tr.rec Tr.REARING_RANK Tr.BIRTH_RANK Tr.ewe_birth_rank Tr.ewe_rearing_rank Tr.age_in_weeks Tr.ch4_GroupNumber Tr.dam_parity_group_num !r Trait.ped(ANI_ID) ide(ANI_ID)

1 2 1
0
Trait 0 US 10 0 14 !GP
Trait.ped(ANI_ID)
Trait 0 US 2 0 16 !GP
ANI_ID

VPREDICT !DEFINE
P Vp1 1 2 5
P Vp2 1 4 7
P Cp 3 6
H h2_1 5 Vp1
H h2_2 7 Vp2
R rg 5 6 7
R re 2 3 4
R cp Vp1 Cp Vp2
