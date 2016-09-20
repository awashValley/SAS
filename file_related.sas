* [Tue, 20SEP2016]. Check if a file exist. ;
  %local _noerr _dsid _nobs;
  %let _noerr=0;

  /* Check if the file exists */
  %if %sysfunc(fileexist("&lgname")) = 0 %then %do;
     %let _noerr=1;
     %put %str(ER)ROR: Physical file does not exist, &lgname.;
     %goto checkend;
  %end;

  /* To clean work */
  proc datasets library = work nolist;
     %if %sysfunc(exist("work._log_out_tmp")) = 0 %then delete _log_out_tmp;;
     %if %sysfunc(exist("work.&outds")) = 0 %then delete &outds;;
  quit;
