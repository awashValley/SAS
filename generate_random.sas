

%MACRO gen_rand(NRecords =,
                seed     =,
                NObs     =,
                out_rand =);
                
  %GLOBAL &out_rand;
  
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
    SELECT randnum into :&out_rand SEPARATED BY ' '
    FROM work.ds_tmp;
  QUIT;
  
  /* Delete temporary dataset. */
  PROC DATASETS LIBRARY=work;
    DELETE ds_tmp;
  RUN;
  QUIT;

%MEND  gen_rand;
     
