
/* ERROR: A character operand was found in the %EVAL function or %IF condition where a numeric
       operand is required. The condition was: &i=13 or */
  * this is due to the presence of "OR". For example,
    data test;
      set inpdata;
      if upcase(cloth) = "TSHIRT" or then
      do;
        /* do sth. */
      end;
    run;

