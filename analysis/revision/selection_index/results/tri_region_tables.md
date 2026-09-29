# Favourable-region tables (i = 1 per generation unless a column says otherwise; three-trait information)

CO2 goal weights and CO2 residual coefficients are per 100 g/d; index weights are per record unit. Coordinates: CH4 = raw traits;
phenotypic / genetic = residual R = CH4 - beta_MBW*MBW - beta_CO2*CO2 with MBW and CO2 alongside. Responses are identical in all coordinate systems.

## Table 1. Genetic parameters (trivariate model) and residual traits

| trait | mean | VA | VP | h2 | r_g_CH4 | r_g_MBW | r_g_CO2 | r_p_CH4 | r_p_MBW | r_p_CO2 |
|---|---|---|---|---|---|---|---|---|---|---|
| CH4 |  17.9 | 4.412 | 16.14 | 0.2733 |     1 | 0.6917 | 0.5718 |     1 | 0.3644 | 0.366 |
| MBW |  22.1 | 3.078 | 5.287 | 0.5822 | 0.6917 |     1 | 0.8289 | 0.3644 |     1 | 0.4999 |
| CO2 |  1190 | 28830 | 70560 | 0.4086 | 0.5718 | 0.8289 |     1 | 0.366 | 0.4999 |     1 |

| residual | coef_MBW | coef_CO2_per100 | VA | VP | h2 | rg_with_CH4 | rg_with_MBW | rg_with_CO2 | rp_with_MBW | rp_with_CO2 |
|---|---|---|---|---|---|---|---|---|---|---|
| phenotypic | 0.4227 | 0.3707 | 2.465 | 13.27 | 0.1857 | 0.7819 | 0.1208 | -0.02738 | 0 | 0 |
| genetic | 0.833 | -0.006092 | 2.301 | 14.22 | 0.1618 | 0.7221 | 0 | 0 | -0.1175 | 0.1403 |

## Table 2. Constructions as defined (no additional weight on MBW/CO2)

| construction | in_region | dCH4 | dMBW | dCO2 | r_IH | goal_CH4_MBW | goal_CH4_CO2 |
|---|---|---|---|---|---|---|---|
| Free three-trait index, CH4 only in the goal | FALSE | -1.338 | -1.213 | -99.57 | 0.6371 | 0 | 0 |
| Ratio CH4/MBW (linearised) | FALSE | -0.7504 | -0.1435 | -2.37 | 0.418 | 0.8102 | 0 |
| Phenotypic residual on MBW | FALSE | -1.081 | -0.5981 | -42.41 | 0.4508 | 0.6367 | 0 |
| Genetic residual on MBW | FALSE | -0.7067 | -0.09021 | 2.243 | 0.4167 | 0.8282 | 0 |
| Phenotypic residual on MBW + CO2 | FALSE | -0.8709 | -0.315 | -9.82 | 0.4467 | 0.4227 | 0.3707 |
| Genetic residual on MBW + CO2 | FALSE | -0.7077 | -0.09135 | 2.003 | 0.4163 | 0.833 | -0.006092 |

## Table 3. Weight ladder inside the region: goals and index weights in each coordinate system

| construction | in_region | dCH4 | dMBW | dCO2 | dCH4_i1.7 | dMBW_i1.7 | dCO2_i1.7 | dCH4_per_yr | dMBW_per_yr | dCO2_per_yr | r_IH |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Largest CH4 cut with MBW held at 0 (restricted index) | TRUE | -0.6307 | 0 | 10.02 | -1.072 | 0 | 17.04 | -0.3829 | 0 | 6.085 | 0.4155 |
| Goal weight on MBW 0.86, CO2 0 | TRUE | -0.6263 | 0.005066 | 10.46 | -1.065 | 0.008612 | 17.78 | -0.3803 | 0.003076 |  6.35 | 0.4155 |
| Goal weight on MBW 0.90, CO2 0 | TRUE | -0.5212 | 0.1245 | 20.69 | -0.8861 | 0.2116 | 35.17 | -0.3165 | 0.07557 | 12.56 | 0.4161 |
| Goal weight on MBW 0.95, CO2 0 | TRUE | -0.3871 | 0.2695 | 33.01 | -0.658 | 0.4582 | 56.12 | -0.235 | 0.1636 | 20.04 | 0.4199 |
| Goal weight on MBW 1.00, CO2 0 | TRUE | -0.2542 | 0.4058 | 44.48 | -0.4322 | 0.6899 | 75.62 | -0.1544 | 0.2464 | 27.01 | 0.4268 |
| Goal weight on MBW 1.05, CO2 0 | TRUE | -0.1268 | 0.5302 | 54.85 | -0.2156 | 0.9014 | 93.24 | -0.07699 | 0.3219 |  33.3 | 0.4365 |
| Goal weight on MBW 1.10, CO2 0 | TRUE | -0.007766 | 0.641 | 63.99 | -0.0132 |  1.09 | 108.8 | -0.004715 | 0.3892 | 38.85 | 0.4483 |

| construction | goal_CH4_CH4 | goal_CH4_MBW | goal_CH4_CO2 | goal_phenotypic_R_p | goal_phenotypic_MBW | goal_phenotypic_CO2 | goal_genetic_R_g | goal_genetic_MBW | goal_genetic_CO2 |
|---|---|---|---|---|---|---|---|---|---|
| Largest CH4 cut with MBW held at 0 (restricted index) |    -1 | 0.8583 | 0 |    -1 | 0.4357 | -0.3707 |    -1 | 0.02527 | 0.006092 |
| Goal weight on MBW 0.86, CO2 0 |    -1 |  0.86 | 0 |    -1 | 0.4373 | -0.3707 |    -1 | 0.02696 | 0.006092 |
| Goal weight on MBW 0.90, CO2 0 |    -1 |   0.9 | 0 |    -1 | 0.4773 | -0.3707 |    -1 | 0.06696 | 0.006092 |
| Goal weight on MBW 0.95, CO2 0 |    -1 |  0.95 | 0 |    -1 | 0.5273 | -0.3707 |    -1 | 0.117 | 0.006092 |
| Goal weight on MBW 1.00, CO2 0 |    -1 |     1 | 0 |    -1 | 0.5773 | -0.3707 |    -1 | 0.167 | 0.006092 |
| Goal weight on MBW 1.05, CO2 0 |    -1 |  1.05 | 0 |    -1 | 0.6273 | -0.3707 |    -1 | 0.217 | 0.006092 |
| Goal weight on MBW 1.10, CO2 0 |    -1 |   1.1 | 0 |    -1 | 0.6773 | -0.3707 |    -1 | 0.267 | 0.006092 |

| construction | index_CH4_CH4 | index_CH4_MBW | index_CH4_CO2 | index_phenotypic_R_p | index_phenotypic_MBW | index_phenotypic_CO2 | index_genetic_R_g | index_genetic_MBW | index_genetic_CO2 |
|---|---|---|---|---|---|---|---|---|---|
| Largest CH4 cut with MBW held at 0 (restricted index) | -0.1727 | 0.08768 | 0.0006901 | -0.1727 | 0.01468 | 0.00004979 | -0.1727 | -0.0562 | 0.0007006 |
| Goal weight on MBW 0.86, CO2 0 | -0.1727 | 0.08852 | 0.0006921 | -0.1727 | 0.01554 | 0.000052 | -0.1727 | -0.05533 | 0.0007026 |
| Goal weight on MBW 0.90, CO2 0 | -0.1717 | 0.1084 | 0.0007407 | -0.1717 | 0.03581 | 0.0001043 | -0.1717 | -0.03464 | 0.0007511 |
| Goal weight on MBW 0.95, CO2 0 | -0.1704 | 0.1332 | 0.0008013 | -0.1704 | 0.06115 | 0.0001696 | -0.1704 | -0.008793 | 0.0008117 |
| Goal weight on MBW 1.00, CO2 0 | -0.1692 | 0.158 | 0.000862 | -0.1692 | 0.08648 | 0.0002349 | -0.1692 | 0.01706 | 0.0008723 |
| Goal weight on MBW 1.05, CO2 0 | -0.1679 | 0.1828 | 0.0009227 | -0.1679 | 0.1118 | 0.0003002 | -0.1679 | 0.04291 | 0.0009329 |
| Goal weight on MBW 1.10, CO2 0 | -0.1667 | 0.2076 | 0.0009834 | -0.1667 | 0.1372 | 0.0003656 | -0.1667 | 0.06876 | 0.0009935 |

## Table 4. Weight windows: goal weight on MBW that reaches the region for a given goal weight on CO2

| goal_w_CO2_per100 | goal_w_MBW_min | goal_w_MBW_max | extra_MBW_phenotypic_min | extra_MBW_phenotypic_max | extra_CO2_phenotypic_per100 | extra_MBW_genetic_min | extra_MBW_genetic_max | extra_CO2_genetic_per100 |
|---|---|---|---|---|---|---|---|---|
|  -1.2 |  1.97 | 2.085 | 1.547 | 1.662 | -1.571 | 1.137 | 1.252 | -1.194 |
|    -1 |  1.78 |  1.92 | 1.357 | 1.497 | -1.371 | 0.947 | 1.087 | -0.9939 |
|  -0.8 | 1.585 |  1.76 | 1.162 | 1.337 | -1.171 | 0.752 | 0.927 | -0.7939 |
|  -0.6 | 1.395 | 1.595 | 0.9723 | 1.172 | -0.9707 | 0.562 | 0.762 | -0.5939 |
|  -0.4 | 1.205 |  1.43 | 0.7823 | 1.007 | -0.7707 | 0.372 | 0.597 | -0.3939 |
|  -0.2 | 1.035 | 1.265 | 0.6123 | 0.8423 | -0.5707 | 0.202 | 0.432 | -0.1939 |
| 0 |  0.86 |   1.1 | 0.4373 | 0.6773 | -0.3707 | 0.02696 | 0.267 | 0.006092 |
|   0.2 |  0.69 | 0.935 | 0.2673 | 0.5123 | -0.1707 | -0.143 | 0.102 | 0.2061 |
|   0.4 | 0.515 |  0.77 | 0.09234 | 0.3473 | 0.0293 | -0.318 | -0.06304 | 0.4061 |
|   0.6 | 0.345 |  0.61 | -0.07766 | 0.1873 | 0.2293 | -0.488 | -0.223 | 0.6061 |
|   0.8 | 0.175 | 0.445 | -0.2477 | 0.02234 | 0.4293 | -0.658 | -0.388 | 0.8061 |
|     1 | 0 |  0.28 | -0.4227 | -0.1427 | 0.6293 | -0.833 | -0.553 | 1.006 |
|   1.2 | -0.17 | 0.115 | -0.5927 | -0.3077 | 0.8293 | -1.003 | -0.718 | 1.206 |

