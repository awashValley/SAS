
* [Thur 28Apr2016]. Compare covariance structures. ;

%macro compareCovariances;
  /*******************************************************************************
    Compare covariance structures.
  *******************************************************************************/

  * Suppress ODS results. ;
  ods results off;
/*  ods listing close;*/

  * Redefine interval variable as charachter variable. ;
/*  data work.analydata_tmp (drop=_interval);*/
/*    length interval $2;  * TEMPORARY;*/
/*    *retain &retain_vars;*/
/*    set work.analydata_tmp(rename= (interval =_interval));*/
/**/
/*    interval =put(_interval, 2.);*/
/*  run;*/

  * Fit different mixed models using candidate covariance structures. ;
  data out_fitAll;
    length Type LogRes $10 Neg2LogLike Parms AIC AICC BIC 8;
    call missing(of _all_);
  run;

  %let cov_list =%str(cs,csh,toep,toeph,arh(1),ar(1)); 
  %let count    =%sysfunc(countw(&cov_list, ",")); 

  %do j=1 %to &count;
    %let cov_type = %qscan(&cov_list, &j, %str(,)); 
    
    proc printto log="&logpath.\mixed_model_&analyBy_label._&cov_type..log" new;
    run;

    ods output InfoCrit=out_fitJ;
    proc mixed data=work.analydata_tmp (where= (&projectBy = "&analyBy")) method=REML ic;
      class treatment &block &id;
      model transf_response = treatment &block treatment*&block /ddfm=KenwardRoger;  /* TEMPORARY: ddfm */
      repeated &block /subject=&id type=&cov_type;
    run;

    proc printto log=log;
    run;

    * check log file for undesirable notes (e.g., non-convergence). ;
    %checkLog(logFile =mixed_model_&analyBy_label._&cov_type);

    * Merge all results. ;
    data work.out_fitJ;
      length Type LogRes $10;
      set work.out_fitJ;

      Type   =symget(strip('cov_type'));
      LogRes =symget(strip('logRes'));
    run;

    data work.out_fitAll;
      set work.out_fitAll 
          work.out_fitJ (keep =Type LogRes Neg2LogLike Parms AIC AICC BIC);
      if Type = " " then delete;
    run;
  %end;

  * Keep only the identified mixed models. ;
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

    do k=1 to dim(nums);

      if nums[k] = lowest then
      do;
        if      upcase(vname(nums[k])) = "AR1" then 
        do;  
          call symput("final_cov", substr(vname(nums[k]),1,2) || strip("(1)") );
        end;
        else if upcase(vname(nums[k])) = "ARH1" then 
        do;  
          call symput("final_cov", substr(vname(nums[k]),1,3) || strip("(1)") );
        end;
        else
        do;
          call symput("final_cov", strip(vname(nums[k])));
        end;
      end;

    end;
  run;

  %put ### Final covariance: &final_cov;
  %put ### Parameter: &parameter;
  %put ### Analysis : &analyBy;
  %put ### Criterion: &criterion;

  * Delete temporary datasets. ;
  proc datasets nolist library=work;
    delete 
      final_ds fit_criterion out_fitJ
      out_fitall;
  run;
  quit;

%mend  compareCovariances;
