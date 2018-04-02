%macro power_fc (rr        =,
			           ref_prop  =,
				         hypo_type =,
				         test_type =,
				         debugme   =n);
							  
	/* Turn on/off debugger. */
	%if       %upcase(&debugme.) eq Y     %then %do;
		options mprint mlogic symbolgen;
	%end;
	%else %if %upcase(&debugme.) eq N or 
			          &debugme.  eq       %then %do;
		options nomprint nomlogic nosymbolgen;
	%end;

	/* Calculate sample size. */
	ods output Output = out_samplesize;
		proc power;
		  twosamplefreq alpha=0.05
		                npergroup=.
		                power=0.80
		                relativerisk=&rr.
		                refproportion=&ref_prop.
		                sides=&hypo_type.
		                test=&test_type.;
		run;
	ods output close;

	/* Return sample size. */
	%global NPerGroup;

	data _null_;
		set work.out_samplesize;

		call symput('NPerGroup', put(NPerGroup, best.));
	run;

	/* House cleaning. */
	proc datasets lib=work memtype=data;
		delete out_samplesize;
	run;
	quit;

%mend power_fc;

** ------------------------------------- ;
** Read metadata of power analysis.      ;
** ------------------------------------- ;
filename mtdt "&proj_fld\metadata power analysis.xlsx";

proc import datafile=mtdt out=metadata
	dbms=xlsx
	replace;
	getnames=yes;
run;

** ---------------------------------------------- ;
** Calculate sample size by experiment type.      ;
** ---------------------------------------------- ;
data _null_;
	length code $ 2000;
	set work.metadata;

	code = catx('',
                cats('%power_fc (rr=', relative_risk, ', 
                                 ref_prop=', control_prop, ', 
                                 hypo_type=', hypothesis, ', 
                                 test_type=', test_type, ', 
                                 debugme=n);'),
				cats('data work.', alergy_type, '_', exper_num, ';'), 
					   'length NPerGroup 8;',
					   cats('exper_num = ', exper_num, ';'),
					   cats('alergy_type = "', strip(alergy_type), '";'),
					   "NPerGroup = input(strip(symget('NPerGroup')), best.);",
			         'run;'
           );

	call execute(code);
run;
