

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

/* [20-Mar-2018]. Generate dataset. */
/* - Source: cc07_SQL or not SQL When Performing Many-to-Many Merge */
data lab;
	length lbtestcd $ 10 lbstresu $ 20 ;
	retain lbtestcd "CREAT" lbstresu "UMOL/L";

	do usubjid=1001 to 6000;
		if ranuni(0)<0.5 then sexcd=1;
		else sexcd=2;

		age=floor(47+sqrt(81)*rannor(1688));
		lbdt=floor(14535+sqrt(219950)*rannor(1688));

		do visitnum= 1 to 6 ;
			lbdt=lbdt+30;
			lbstresn = 70+sqrt(200)*rannor(1688);

			format lbdt yymmdd10.;

			label
				usubjid ='Unique Subject Identifier'
				sexcd ='Sex Code 1=male 2=female'
				age ='Age in Years'
				lbdt ='Parameter Measurement Date'
				lbstresn ='Parameter Value'
				lbtestcd ='Parameter Name'
				lbstresu ='Parameter Unit'
				visitnum ='Visit identifier (numeric)'
			;
			output;
		end;
	end;
run;
     
