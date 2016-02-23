
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
  %let block =%str(survival\data);
  libname dlbIn "&mpath.\&block";  

  proc print data=dlbIn.infecdd(obs=5);
  run; 
  
* [27JAN2016]. remove all formats, labels, informats. ;
  proc datasets lib=<your library> memtype=data nolist;
    modify <your dataset>; 
      attrib _all_ label=' '; 
      attrib _all_ format=;
      attrib _all_ informat=;
  run;
  
 * [23FEB20016] Create data set with missing values. ;
   data work.test;
     length a $ 20
            b 8
            c 3
	    d $ 40
	    e 8;
    format a $10.;
    call missing(of _all_);
  run;
