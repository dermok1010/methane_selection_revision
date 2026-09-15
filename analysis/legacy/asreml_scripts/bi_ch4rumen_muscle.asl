 ASReml 4.2ni [27 Mar 2023] bivariate_ch4_vs_weight
 >> Linux (x64)    4.9 Gbyte  bi_ch4rumen_muscle  28 Mar 2026 15:18:46.728
 PEDA30      330812

 Bivariate analysis of methane_per_rumen and ct_muscle_kg                                    
 Summary of 780 records retained of 15869 read
 Notice: This job may require more workspace.
 LXBASE,LYXZ,KYXZ,KFBASE,KEY,KCV,TYFACT,NCOVAR,NRF
     50996     31872      3185     70114      3248    101992    102000         1         3
 Forming   995342 equations:    36 dense.  332264 hidden.
 Restarting iteration using bi_ch4rumen_muscle.rsv
           1                   780
      0      1      2      1      0      0      0

 Counts:   3: 7832 105193 0 55423 0 23878 0 10253 0 4473 0 1839 0 831 0 536 0 549 0 202

 At 204055: 0 <= 4, 105196 <= 6 and 55423 = 7

 Counts:   3: 1664 12453 0 13962 0 2755 0 649 0 206 0 77 0 38 0 145 0 310 0 72

 At 31010: 0 <= 4, 29170 <= 10 and 649 = 11

 Counts:   3: 7 1 0 3 0 4 0 51 0 32 0 6 0 15 0 152 0 213 0 143

 At 916: 0 <= 12, 193 <= 19 and 178 = 21

 At 758: 27 <= 19, 239 <= 24 and 92 = 25

 At 532: 0 <= 24, 239 <= 29 and 75 = 31

 At 300: 3 <= 29, 123 <= 35 and 1 = 37

 At 177: 0 <= 35, 16 <= 42 and 10 = 43

 Counts:  36: 1 0 10 0 5 0 10 0 19 0 6 0 2 0 4 0 1 0 8 0

 At 135: 0 <= 46, 23 <= 57 and 2 = 59

 Counts:  46: 6 0 2 0 2 0 1 0 7 0 5 0 2 0 4 0 5 0 1 0

 At 113: 0 <= 65, 4 <= 73 and 1 = 75

 Counts:  66: 1 0 2 0 1 0 0 0 1 0 2 0 2 0 3 0 4 0 3 0
E64AvePos  18      37       1  661808
E64AvePos  19      38       1  661809
E64AvePos  20      39       1  661810
E64AvePos  21      40       1  661811
E64AvePos  22      41       1  661812
E64AvePos  23      42       1  661813
E64AvePos  24      43       1  661814
E64AvePos  25      44       1  661815
E64AvePos  26      45       1  661816
E64AvePos  27      46       1  661817
E64AvePos  28      47       1  661818
E64AvePos  29      48       1  661819
E64AvePos  30      49       1  661820
E64AvePos  31      50       1  661821
E64AvePos  32      51       1  661822
E64AvePos  33      52       2  661823
E64AvePos  34      54    1435  662542
E64AvePos  35    1489    2870  630817
E64AvePos  36    4359  330812     470
E64AvePos  37  335171  330812   -6278
E64AvePos  38  665983  661624     -73
 Order           3               3333645     4651023             172407310
             177069266             354137828
 Singularity Tests Value  5.000000000000000E-008           0           0
 >> >>      ASReml Process        CPU_time     SumCPU        Clock   SumClock
 >> >>       ShuffleE 2500: sec       2.47       2.47         2.54       2.54
 FILLIN 3333645 ==>> 3373305    1.01, #SR: 661770, AvLen: 4, MxLen: 157, AvFlops: 11
  >> LL2 blocks        15384   4.063703    
LAKEYA(NEQ+1),LAKEYX(NEQD),LAKEYX(NEQD),MAXWVS,  LBWV,  LBWK   174413349   177068562
   173695257    33411444         704    66823592   177069266   133646480   134974088   179724479
 VWVA 556          37     1327607         318     1347648
 >> >>  Iteration complete: sec      19.51      21.98         1.44       3.99

        : ide(ANI_ID) dropped from model because variance is negligible.
        : but it could be just an issue of the scale of a variate.
   1 LogL= -642.661     S2=  1.0000         1386 df
      0      1      2      1      0      0      0
 Singularity Tests Value  5.000000074505806E-009           0           0
 XXAO_KEYA   171040044   174413349     3373305
 XXAO_KEYA           1           1
  >> LL2 blocks        15384   4.063703    
LAKEYA(NEQ+1),LAKEYX(NEQD),LAKEYX(NEQD),MAXWVS,  LBWV,  LBWK   174413349   177068562
   173695257    33411444         704    66823592   177069266   133646480   134974088   179724479
 VWVA 556          37     1327607         318     1347648
 >> >>  Iteration complete: sec      23.58      45.56         1.71       5.70
   2 LogL= -642.661     S2=  1.0000         1386 df
 >> >>     Iterations done: sec       0.00      45.56         0.00       5.70
 ide(ANI_ID)           IDV_V 330812   0.00000       0.00000       0.00   0 B
 Residual                US_V  1  1  0.240599      0.240599       5.17   0 P
 Residual                US_C  2  1 -0.702413E-01 -0.702413E-01  -1.23   0 P
 Residual                US_V  2  2  0.666344      0.666344       4.87   0 P
 Trait.ANI_ID            US_V  1  1  0.142422      0.142422       2.86   0 P
 Trait.ANI_ID            US_C  2  1  0.469228E-01  0.469228E-01   0.76   0 P
 Trait.ANI_ID            US_V  2  2  0.605163      0.605163       3.98   0 P
 >> >> ASR/SLN/YHT written: sec       1.42      46.98         1.48       7.18
 >> >>            Finished: sec       0.00      46.99         0.00       7.18
 Finished: >> 28 Mar 2026 15:18:58.   LogL Converged
 Finished:       bi_ch4rumen_muscle
