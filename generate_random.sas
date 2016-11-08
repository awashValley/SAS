

%GLOBAL out_rand NRecords;
  
%MACRO gen_random(dsin     =,
                  NObs     =,
                  seed     =,
                  debugme  =);  
  
  /* Debugging tools */
  %IF       %UPCASE(&debugme) = Y %THEN %DO;
    OPTIONS MPRINT MLOGIC SYMBOLGEN;
  %END;
  %ELSE %IF %UPCASE(&debugme) = N %THEN %DO;
    OPTIONS NOMPRINT NOMLOGIC NOSYMBOLGEN;
  %END;  
   
  /* Determine number of observations in input dataset */
  DATA _NULL_;
     SET &dsin. END=LAST;
  
     IF LAST THEN CALL SYMPUT('NRecords', _N_);
  RUN;  
  
  /* Generate random uniform numbers between a range. */
  /* - SOURCE: http://blogs.sas.com/content/iml/2011/08/24/how-to-generate-random-numbers-in-sas.html */
  DATA ds_tmp;
    CALL STREAMINIT(&seed);
    
    %DO i = 1 %TO &NObs;
      u = rand("Uniform");
      randnum = 1 + floor(&NRecords * u); 
      
      OUTPUT;
    %END;
  RUN;

  /* Create a macro variable with random values. */
  PROC SQL NOPRINT;
    SELECT randnum into :out_rand SEPARATED BY ' '
    FROM work.ds_tmp;
  QUIT;
  
  /* Delete temporary dataset. */
  PROC DATASETS LIBRARY=work;
    DELETE ds_tmp;
  RUN;
  QUIT;

%MEND  gen_random;
     
