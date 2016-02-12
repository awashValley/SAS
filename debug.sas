
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

