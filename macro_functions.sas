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
  
* [Tue 29Mar2016]. Loop over string values (source: http://support.sas.com/kb/26/155.html). ;
  %macro loop(values);    
    /* Count the number of values in the string */                                                                                                                                   
    %let count=%sysfunc(countw(&values)); 

    /* Loop through the total number of values */                                                                                         
    %do i = 1 %to &count;                                                                                                              
      %let value=%qscan(&values,&i,%str(,));                                                                                            
      %put &value;                                                                                                                      
    %end;                                                                                                                              
  %mend;                                                                                                                                  
                                                                                                                                        
  /* %STR is used to mask the commas from the macro compiler when */                                                                      
  /* the macro %LOOP is called.                                   */                                                                      
  %loop(%str(2,3,5,7,11,13,17)) 
