/* Remove any duplicate records using "noduprec" option. */
  proc sort data=work.test noduprec;
    by varx;
  run;
  
/* [19SEP2016]. Save duplicate keys */  
  PROC SORT DATA=work.checkkey NODUPKEY DUPOUT=work.dups;
    BY var1 var2;
  RUN;
