/*******************************************************************************
   
********************************************************************************
  Program     : checkLog.sas
  Author      : 
  Location    : 
  Date        : 01JUN2016
  Version     : 
  Description : It checks the log file of the fitted mixed model for undesirable 
                notes.                             
  Remarks     : 
********************************************************************************
  Input       : - &logFile : the name of input log file. 
  Output      : - &logRes  : a macro variable with a value either "logNotOK" or
                             "logOK" depending on the search result for 
                             undesirable notes.
********************************************************************************


%macro checkLog(logFile =);

  * Modify input logFile name. ;
  %let logFile =&logFile..log;

  * Import log file and filter the findings. ;
  data work.log;
    infile "&logpath.\&logFile" truncover lrecl=200;
    length notes $ 200;
    input @1 notes $char200.;
  run;

  data work.log2 (drop =notes);
    length findings $200;
    set work.log (where = (notes like '%NOTE%' or
                           notes like '%WARN%' or
                           notes like '%ERR%'));

    findings =tranwrd(notes, 'NOTE: ', ' ');
  run;

  * Check for undesirable notes in the imported log file. ;
  %let logi =%sysfunc(compress(%sysfunc(catx(%str( ), %, &undesNote2, %))));

  data logRes;
    set log2 (where = (   findings like '%but final hessian is not positive definite%'  
                       or findings like '%Estimated G matrix is not positive definite%' 
                       or findings like '%Asymptotic variance matrix of covariance parameter estimates has been found to be singular%' 
                       or findings like '%An infinite likelihood is assumed%' 
                       or findings like '%A linear combination of covariance%' 
                       or findings like '%A linear combination of covariance%' 
                       or findings like '%At least one element of the (projected) gradient is greater than%' 
                       or findings like '%Stopped because of too many likelihood evaluations%' 
                       or findings like '%MIVQUE0 estimate of profiled variance%' 
                       or findings like '%Pseudo-likelihood update fails%' or findings like '%The initial estimates did not yield a valid objective function%' 
                       or findings like '%The final Hessian matrix is full rank but has at least one negative eigen value%')
                      );

  run;

  * Count number of issues found in the log file. ;
  proc sql noprint;
    select count(*) into :num_logs 
    from work.logres;
  quit;

  %if &num_logs >= 1 %then 
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
      log log2 logres;
  run;
  quit;

%mend  checkLog;
