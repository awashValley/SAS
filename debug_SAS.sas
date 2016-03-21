
/* ERROR: A character operand was found in the %EVAL function or %IF condition where a numeric
       operand is required. The condition was: &i=13 or */
  * This error is caused by the presence of "OR" in the IF statement. ;
    data test;
      set inpdata;
      if upcase(cloth) = "TSHIRT" or then
      do;
        /* do sth. */
      end;
    run;
    
    
/* [Fri 18Mar2016]. SAS macro sometimes doesn't run after some line. WHY? 
                    - I found that my macro name was renamed, but I forgot to change the old macro name in "%include(old_macro_name)". 
                    - The reason why SAS still runs without any errors and warnings, becuase SAS can still see and run the program in the old macro name. 
                    - Thus, the solution is to change the old macro name in the "%include(old_macro_name)" statement. */


/* [Mon 21Mar2016]. Don't compare macro variable value with another value within a quotation. Rather, remove the quotation. */
   %let transf =none;
   
   %if       %upcase(&transf) ="NONE"  %then /* do something. */;    /* WRONG!!! */
   %if       %upcase(&transf) =NONE    %then /* do something. */;    /* CORRECT!!! */


/* [Mon 21Mar2016]. Don't forget to close the macro. */
   %if       %upcase(&transf) =NONE  %then transf_response =response;   /* WRONG since SAS expects the macro to be close. 
                                                                             Then, SAS checks macro issues and continue with excustion. */
   
   %if       %upcase(&transf) =NONE  %then 
   %do;  transf_response =response;
   %end;                                                                /* CORRECT!!!*/
