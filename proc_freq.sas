/* [26-jun-2017]. suppress percent and count columns. */
proc freq data = insdtm.suppis;
  tables qnam / out = work.__chk_suppis (drop = count percent);
run;
