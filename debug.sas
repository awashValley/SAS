
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

