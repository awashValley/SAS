
* [Wed 06Apr2016]. Check log file for undesirable notes after fitting mixed models. 
  Different covariance structures are used (e.g., AR-1, ARH-1, TOEP, TOEPH, CS, and CSH. ;
%macro checkLog(logFile =);

  * Get log file. ;
  filename logs pipe "dir /s /b ""&logpath.\&logFile..log"" "; 
  
  data work.log;
    infile logs dsd dlm="00"x;
    length filename $ 1000;
    input filename $;

    call symput("filename", strip(filename));
  run;

  filename logs;

  * Check log file if any undesirable notes exist. ;
  filename logres pipe "findstr /i /n /g:""&logpath.\search.txt"" ""&filename"" ";

  data work.logres;
    infile logres dsd dlm="00"x;
    length filename line $ 1000;
    input line $;
    
    filename = tranwrd("&filename", "&logpath", "");
  run;

  filename logres;

  proc sql noprint;
    select count(*) into :obs 
    from work.logres;
  quit;

  %if &obs >= 1 %then 
  %do;
    %let logRes =%str(logNotOK);
  %end;
  %else
  %do;
    %let logRes =%str(logOK);
  %end;  

  * Delete temporary datasets. ;
  proc datasets library=work;
    delete 
      log logres;
  run;
  quit;

%mend  checkLog;
