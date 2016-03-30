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
  
* [Tue 30Mar2016]. Loop over string values (source: http://support.sas.com/kb/26/155.html). ;
  %macro test;
    %let cov_list =%str(ar(1),arh(1),cs,csh,toep,toeph); 
    %let count    =%sysfunc(countw(&cov_list, ",")); 

    %do i=1 %to &count;
      %let value = %qscan(&cov_list, &i, %str(,));                                                                                            
      %put &value; 
    %end;
  %mend test;

  %test;
  

* [Wed 30Mar2016]. Create macro variables within data statement. ;
  data work.test;
    set work.tmp;
  
    call symput("studynum" || compress(put(i, 8.)), trim(studynum));
run;


