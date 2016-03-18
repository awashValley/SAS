
/* [08FEB2016]. Log File (NOTE): Character to numeric conversions...
                Debug: Use an INPUT statement since MDY is a numeric function. */
   if   length(varChar)=10 then varNum=mdy(input(substr(varChar, 6, 2), 8.), 
	                                   input(substr(varChar, 9, 2), 8.), 
	                                   input(substr(varChar, 1, 4), 8.));
   else                         varNum=.;
   
   
/* [12FEB2016] Becareful using NODUPKEY option in PROC sort. */

/* [12FEB2016] TRIM() vs STRIP(): the later is preferred if we want to trim front and back white spaces. */

/* [15FEB2016] try to check always if derivation of date from the source data set is done correctly and successfully. 
               - [How to do it?] compare source data set against the target data set. 
               - [It could go wrong?] The following derivation, for example, is wrong since only year information is available 
                  for the variable "visity".  */
                 
                        if   visity^=. then vardt=          substr(put(visity, mmddyy10.), 7, 4)
                                                  || "-" || substr(put(visity, mmddyy10.), 1, 2)
                                                  || "-" || substr(put(visity, mmddyy10.), 4, 2);
	                else                vardt=" ";
	        
	        /* [How to fix it?] The above derivation assumes there are values for the day, month and year. However, the variable "visity" has 
	          only the year value (e.g., visity=1976). In that case, the correct derivation should be */
	          	
	          	if   visity^=. then vardt=put(visity, 4.);
	                else                vardt=" ";
                 
                 
/* [Fri 18Mar2016]. Use percent(%) before IF statment whenever we evaluate a macro variable inside DATA statement. */
   data work.temp;
     set work.test;

     %if %lowcase(&criterion) Eq bic %then
     %do;
      where index(lowcase(Descr), "bic (smaller is better)") > 0;
     %end;
     %else
     %do;
       where index(lowcase(Descr), "&criterion. (smaller is better)") > 0;
     %end;
   run;
