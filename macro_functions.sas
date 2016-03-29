* How to include list of strings as value for an argument. ;
  %update_values(inset  =domx&&studynum&i
                ,outset =domx&&studynum&i
	  	,sortvar=%str(studyid, siteid, subjid, visitn, var1, var2, var3)
		,domain =domx);
		
* [Fri 18Mar2016]. Provide default value for a macro. ;
  %macro compareCovariances(sdata     = 
                           ,parameter =
                           ,gender    =
                           ,criterion =bic);
                           
    data work.temp;
      set work.test;

      %if %lowcase(&criterion) Eq bic %then
      %do;	/* use default value */
        where index(lowcase(Descr), "bic (smaller is better)") > 0;
      %end;
      %else	
      %do;	/* apply user's value */
        where index(lowcase(Descr), "&criterion. (smaller is better)") > 0;
      %end;
    run;
    
  %mend  compareCovariances;
  
* [Tue 29Mar2016]. Loop over string values. ;
  %let cov_list =%str(cs csh toep toeph ar1 ar1h); 
  %let count    =%sysfunc(countw(&cov_list));
