!WORKSPACE 5000 !CONTINUE !NODISPLAY !LOGFILE
heritability test
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
 ct_muscle_kg 1
 ch4_adj_MBW 1
 ch4_adj_DMI 1
 ch4_adj_adg 1

pedigree_full_sas_style.csv.SRT
P3_data.csv !SKIP 1 !MVINCLUDE

methane_per_rumen ~ mu SEX TX BR SU CL CV LY UN het rec REARING_RANK BIRTH_RANK ewe_birth_rank ewe_rearing_rank age_in_weeks dam_parity_group_num ch4_GroupNumber !r ped(ANI_ID) ide(ANI_ID)

VPREDICT !DEFINE
P Phen 1 2 3 
H direct 1 4
P ani_all 1 2
H repeat 5 4
