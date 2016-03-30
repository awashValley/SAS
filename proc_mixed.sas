
* [Wed 30Mar2016]. Fit different mixed models and save AIC values. ;
  data out_fitStat_all;
    length Type $10 Neg2LogLike Parms AIC AICC BIC 8;
    call missing(of _all_);
  run;

  %let cov_list =%str(ar(1),arh(1),cs,csh,toep,toeph); 
  %let count    =%sysfunc(countw(&cov_list, ",")); 

  %do i=1 %to &count;
    %let cov_type = %qscan(&cov_list, &i, %str(,)); 
    
    ods output InfoCrit=out_fitStat_i;
    proc mixed data=work.test method=REML ic;   /* "ic" is responsible for saving the AIC values. */
      class treatment interval id;
      model transf_response = treatment interval treatment*interval /ddfm=KenwardRoger;  
      repeated interval /subject=id type=&cov_type;
    run;

    data out_fitStat_i;
      length Type $10;
      set out_fitStat_i;
      Type = "&cov_type";
    run;

    data out_fitStat_all;
      set out_fitStat_all 
          out_fitStat_i (keep =Type Neg2LogLike Parms AIC AICC BIC);
      if Type = " " then delete;
    run;

  %end;
