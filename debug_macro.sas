
%macro updat_data;

  %if %upcase(&&studynum&i)=blahblah %then
  %do;
	  
		/* do sth. */
		
		%let records=0;
		proc sql noprint;
		  select count(*)
			into :records
			from rawdata.mydat;
		quit;		
		%put ###NOTE: [A] [&&studynum&i] [&records.];
  %end;
  %else
  %do;  
	
				
		  %let records=0;
		  proc sql noprint;
  		  select count(*)
			  into :records
			  from mydat&&studynum&i;
		  quit;		
		  %put ###NOTE: [A] [&&studynum&i] [&records.];
				
	    /* do sth. */

  %end;


	%let records_before=0;
	proc sql noprint;
	  select count(*)
		into :records_before
		from mydat&&studynum&i;
	quit;		
	
  data mydat&&studynum&i;
    set mydat&&studynum&i;

    /* do sth. */
	
	  %let records_after=0;
	  proc sql noprint;
	    select count(*)
		  into :records_after
		  from mydat&&studynum&i;
	  quit;		
	
	%let records_diff=%eval(&records_before. - &records_after.);
	%put ###NOTE: [B] [&&studynum&i] [&records_diff.];
	
	%let unique_subj_a=0;
	%let unique_subj_b=0;
	proc sql noprint;
	  select count(distinct catx('-', siteid, subjid))
		into :unique_subj_a
		from mydat&&studynum&i;
		
	  select count(distinct catx('-', siteid, subjid))
		into :unique_subj_b
		from mydat2&&studynum&i;
	quit;
	
	%let unique_diff=%eval(&unique_subj_b - &unique_subj_a);
	%put ###NOTE: [C] [&&studynum&i] [&unique_diff.];
	
	
  /* do sth. */
  
  	
	%let count_out=0;
	proc sql noprint;
	  select count(*)
		into :count_out
		from mydat&&studynum&i;
	quit;			
	
	%let count_exp=%eval(&records - &records_diff + &unique_diff);
	
	%put ###NOTE RESULT: actual = &count_out     expected = &count_exp.;
	
%mend updat_data;

%updat_data;



/* [Mon 04Apr2016]. SAS Macro Error Messages. ;
  1. http://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#n1mcxptbxr3qhwn1q6swv33z8akq.htm */

