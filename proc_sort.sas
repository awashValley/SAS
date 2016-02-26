/* Remove any duplicate records using "noduprec" option. */
  proc sort data=work.test noduprec;
    by varx;
  run;
