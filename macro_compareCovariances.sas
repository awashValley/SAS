%macro compareCovariances;
  /*******************************************************************************
    Compare covariance structures.
  *******************************************************************************/

  * Suppress ODS results. ;
  ods results off;

  * Fit the candidate mixed models. ;
  data out_fitAll;
    length Type LogRes $10 Neg2LogLike Parms AIC AICC BIC 8;
    call missing(of _all_);
  run;

  %let cov_list =%str(cs,csh,toep,toeph,arh(1),ar(1)); 
  %let count    =%sysfunc(countw(&cov_list, ",")); 

  %do i=1 %to &count;
    %let cov_type = %qscan(&cov_list, &i, %str(,)); 
    
    proc printto log="&logpath.\mixed_model_&cov_type..log" new;
    run;

    ods output InfoCrit=out_fitI;
    proc mixed data=work.analydata_tmp method=REML ic;
      class treatment interval animal;
      model transf_response = treatment interval treatment*interval /ddfm=KenwardRoger;  /* TEMPORARY: ddfm */
      repeated interval /subject=animal type=&cov_type;
    run;

    proc printto log=log;
    run;

    * check log file for undesirable notes (e.g., non-convergence). ;
    %checkLog(logFile =mixed_model_&cov_type);

    * Merge all results. ;
    data work.out_fitI;
      length Type LogRes $10;
      set work.out_fitI;

      Type   =symget(strip('cov_type'));
      LogRes =symget(strip('logRes'));
    run;

    data work.out_fitAll;
      set work.out_fitAll 
          work.out_fitI (keep =Type LogRes Neg2LogLike Parms AIC AICC BIC);
      if Type = " " then delete;
    run;
  %end;

  * Keep identified mixed models. ;
  data work.out_fitAll;
    set work.out_fitAll;
    where upcase(LogRes) = "LOGOK";

    if      upcase(Type) = "AR(1)"  then Type="ar1";
    else if upcase(Type) = "ARH(1)" then Type="arh1";
  run;

  * Get values of the preferred criterion. ;
  data work.fit_criterion;
    set work.out_fitAll;

    %if        %upcase(&criterion) Eq BIC  %then
    %do;  
      fitVal =round(bic, 0.1);
      keep type fitVal;
    %end;
    %else %if  %upcase(&criterion) Eq AICC %then
    %do;  
      fitVal =round(aicc, 0.1);
      keep type fitVal;
    %end;
    %else      
    %do;
      fitVal =round(aic, 0.1);
      keep type fitVal;
    %end;
  run;   

  * Compare and get the final covariance structure. ;
  proc transpose data=work.fit_criterion
                   out=work.final_ds(drop  = _name_);
    id Type;
    var fitVal;
  run;

  proc sql noprint;
    select name into :names       separated by ' '
    from dictionary.columns    
    where     upcase(libname) = "WORK" 
          and upcase(memname) = "FINAL_DS" 
    ;

    select name into :names_comma separated by ','
    from dictionary.columns
    where     upcase(libname) = "WORK" 
          and upcase(memname) = "FINAL_DS" 
    ;
  quit;

  data _null_;
    set work.final_ds;

    array nums [*] &names;
    lowest = min(&names_comma);

    do i=1 to dim(nums);

      if nums[i] = lowest then
      do;
        if      upcase(vname(nums[i])) = "AR1" then 
        do;  
          call symput("final_cov", substr(vname(nums[i]),1,2) || strip("(1)") );
        end;
        else if upcase(vname(nums[i])) = "ARH1" then 
        do;  
          call symput("final_cov", substr(vname(nums[i]),1,3) || strip("(1)") );
        end;
        else
        do;
          call symput("final_cov", strip(vname(nums[i])));
        end;
      end;

    end;
  run;

  %put ### Final covariance: &final_cov;
  %put ### Parameter: &parameter;
  %put ### Analysis : &analyby;
  %put ### Criterion: &criterion;

  * Delete temporary data sets. ;
  proc datasets library=work;
    delete 
      final_ds fit_criterion out_fiti
/*      out_fitall */
  run;
  quit;

%mend  compareCovariances;

%compareCovariances;
