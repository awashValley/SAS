
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
  
* [26FEB2016] file names which has a space (e.g., my data.csv). ;
   %let path     =C:\Users\...;
   %let filepath =my data.csv;
   
   %macro readCSV(file, ds);
      data &ds.;
        infile "&path.\&file." dsd dlm="," missover lrecl=32767 firstobs=2;
        length ...;
        input ...;
      run;
  %mend readCSV;
  
  /* Read the file. */
  %readCSV(&filepath, test);
  
  /*[13:17 MON 14MAR2016]. Convert macro variables type and use it in conditional statement. 
                           The "SYSEVALF" function. */
  proc sql noprint;
    select max(age) into :max_age
    from work.out_summary;
  quit;
  
  %let max_age =%sysevalf(&max_age);

  * Define amount of change on y-axis. ;
  %if %sysevalf(&max_age > 700) %then 
  %do;
    /* do something. */
  %end;
  %else 
  %do;
    /* do something. */
  %end;
  
* [Thur 07Apr2016]. Evaluate not missing macro variable. Use a quotation in the %LET. ;
  %let exclSubject =%str(&id IN (2));    /* Doesn't work since SAS can not evaluate IN operator in the IF condition. */
  %let exclSubject =%str("&id IN (2)");  /* Hola */
  
  %macro test;

    %if &exclSubject NE %then
    %do;
      %put ### Not empty;
    %end;
    %else
    %do;
      %put ### empty;
    %end;
  %mend  test;

  %test;
  
  
* [Fri 08Apr2016]. Concatenate macro variables. ;
  proc sql noprint;
    select cats(strip(' " '), catx(" ", 'Group', treatment), strip(' " ')) into :legend_all separated by ' ' 
    from work.Out_summary_combined
    ;

    select count(treatment) into :num_groups
    from work.Out_summary_combined
    ;
  quit;

* [Mon 09May2016]. Remove/replace separator. ;
  %let dotNET2SAS_excluded_rows =3 * 5 * 8;		
  %let excluded_rows 		        =%sysfunc(tranwrd(&dotNET2SAS_excluded_rows, *, %str()));
  

