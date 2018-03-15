
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
   %if       %upcase(&transf) =NONE  %then transf_response =response;   /* WRONG since SAS expects the macro to be closed. 
                                                                             Then, SAS checks macro issues and continue with excustion. */
   
   %if       %upcase(&transf) =NONE  %then 
   %do;  transf_response =response;
   %end;                                                                /* CORRECT!!!*/
   
   
/* [01APR2016]. Error: File Name value exceeds maximum length of 201 characters.
                Solution: This occurs when we specify the filename path in "datafile" directly. Thus, use the "filename" option. */
   filename ff "&dir.\&first_file";

   proc import datafile  =ff
                 out     =work.sample
                dbms     =csv replace;             
                getnames =YES;
   run;
   
   /* [Thur 26MAY2016]. Flag things you would like to change latter.  
                        - The string "workOnThisPart" is mandatory, but the other text is optional. */
      %put "ERR2" "OR: workOnThisPart; blah blah."; 
      
  /* [15-FEB-2018]. Refresh SAS if it is hanging somewhere. */
  /* source: https://communities.sas.com/t5/Base-SAS-Programming/quot-NOTE-49-169-The-meaning-of-an-identifier-after-a-quoted/td-p/121796*/
  ;*%mend;*);*';*";**/;
  run;


/* [15-Mar-2018]. Terminate execution of macro using %goto */
%MACRO GETCON;
       %DO I = 1 %TO &N;
       %IF &&M&I = 0 %THEN %GOTO OUT;
       
       IF CON = &&M&I THEN CON&I = 1;
       ELSE CON&I = 0;
       
       %OUT: %END;
%MEND GETCON; 

/* Another %GOTO example from Joris D. */
%LET ERR = ;

%MACRO TEST;
  %IF 1 = 1 %THEN %LET ERR = HELLO WORLD; %MEND;

%MACRO NEXT;
  %IF &ERR ^= %STR() %THEN %DO;
    %PUT NOT RUNNING. THERE WAS AN ERR SOMEWHERR: &ERR;
    %GOTO M_EXIT;
  %END;
  
  DATA work.not-run;
  RUN;
  
  %M_EXIT:
    %PUT END;
%MEND;

%TESt;
%NEXT;

