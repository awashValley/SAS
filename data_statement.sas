
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
  
 * [23FEB2016] Create data set with missing values. ;
   data work.test;
     length a $ 20
            b 8
            c 3
	    d $ 40
	    e 8;
    format a $10.;
    call missing(of _all_);
  run;
  
 * [24FEB2016] Create a variable with missing value. ;
   varTest=.c;

 * [25FEB2016] Create data set without CARDS. ;
   data work.results;
     length test result $200;

     test = "Number of records"; 
     result = strip("&numberofrecords."); 
     output;

     test = "Number of formats"; 
     result = strip("&numberofformats."); 
     output;

     test = "Longest label"; 
     result = strip("&longestlabel."); 
     output;
    run;
    
 * [MON 15Mar2016 10:15]. Reshape long to wide. ;
   proc sort data=work.long out=work.long_sort;
     by id;
   run;

   data wide1;
     set long_sort;
     by id;

     keep id treatment resp1 - resp12;
     retain resp1 - resp12;

     array aresp(1:12) resp1 - resp12;

     if first.id then
     do;
       do i = 1 to 12;
         aresp(i) =.;
       end;
     end;

     aresp(time) =resp;

     if last.id then output;
   run;
