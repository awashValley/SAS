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
      %else	/* if the user provides a value */
      %do;
        where index(lowcase(Descr), "&criterion. (smaller is better)") > 0;
      %end;
    run;
    
  %mend  compareCovariances;
