
* concatenate macro variables. ;
  %let sep_s =%str();
  %let val1 = value1;
  %let val2 = value2;
  
  %let fval = &val1&sep_s&val2;
  %put fval;
  
* loop over a list in macro variable. ;
  %macro validMacro_all(domains=);
  
  /*  %do i = 1 %by 1 %while(%scan(&domians, i) ne '');*/
    %do i=1 %to 9;
      %let domain = %scan(&domains, &i);
  
  	  /* do the job */
    %end;
  %mend  validMacro_all;
  
  %let domains = a b c d e;
  %validMacro_all(domains=&domains);

/* usage of macro variable as libname. Double dots are used, i.e., 
   the first dot is for ending the macro variable and the other is for accessing the data. */
  proc sort data=allformats
            out =&outlib..allformats;
    by name value;
  run;

