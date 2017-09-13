/* [Wed, 13-Sep-2017]. Survival analysis. */
proc lifetest data=test outsurv=test_out alpha=0.05 conftype=linear;
where trtgrpn=1;
time time*cnsr(1);
ods output quartiles=qgrp1ln productlimitestimates=plegrp1ln censoredsummary=csgrp1ln;
run;

proc lifetest data=test alpha=0.05 conftype=linear;
time time*cnsr(1);
test trtgrpn;
ods output logforstepseq=lgrnk;
run;
