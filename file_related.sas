* [Tue, 20SEP2016]. Check if a file exist. ;
  %local _noerr _dsid _nobs;
  %let _noerr=0;

  /* Check if the file exists */
  %if %sysfunc(fileexist("&lgname")) = 0 %then %do;
     %let _noerr=1;
     %put %str(ER)ROR: Physical file does not exist, &lgname.;
     %goto checkend;
  %end;
