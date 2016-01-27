
* [15JAN2016]. Initialize a variable. ;
   data random;
     length seedLs $ 20;
     retain seedLs;
		  
     /* DO z JOB */
   run;
  
  
* [15JAN2016]. Concatenate variable values within a loop. ;
   data random;
     * initialize the variable (to be concatenated). ;
     length seedLs $ 20;
     retain seedLs;

     %do i=1 %to &max;
       random_int = int(ranuni(&seed) * &nRec + 0);
       seedLs = catx(" ", random_int, seedLs);
     %end;
     
     * create a macro variable. ;
     call symput("seedLs", seedLs);
   run;
   
   /* REMARK: You can't create a macro variable and with CALL SYMPUT and use it in the same DATA step
   	      because SAS doesn't assign a value to the macro variable until the DATA step excutes. */
   	      
   	      
* [27JAN2016]. read data using macro variable. ;
  libname mylib "&idpath.\Analysis\";
  %let ddat = dm;
  
  data test;
    length agegrp   $5;	
    set mylib.&ddat(keep  =&keepvars_dm
	            rename=(&renamevars_dm));
  run;
