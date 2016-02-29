/* 
  --- Paper AD20: Catch the Bad Guys!!! ---
  --- A Utility Program to Check SAS®Log Files ---
  --- Amit Baid, ICON Clinical Research, Smyrna, GA --- 
*/


%macro scanlog (path=);
	 options nodate nonumber noxwait;
	 %let path=%sysfunc(tranwrd(&path,/,\));

	 ** Delete the previous version **;
	 x(del &path\files.txt);

	 ** Output the list of files to a temporary location **;
	 x(dir /b &path\*.log >> &path\files.txt);

	 ** Initialize the macro variables **;
	 %let totfile=;
	 %let totobs=;

	 ** Get the total number of files and file names **;
	 data _null_;
	 infile "&path\files.txt" dsd dlm='09'x truncover;
	 input name $40.;
	 call symput('totfile',trim(left(put(_n_,8.))));
	 call symput('file'||trim(left(put(_n_,8.))),trim(left(name)));
	 run;
	 %do i=1 %to &totfile;
		 data files;
			 infile "&path\&&file&i" dsd dlm='09'x truncover;

			 input line $200.;
			 length filenm $40.;
			 filenm="&&file&i";

			 if index(line,'fatal') then cnt1+1;
			 if substr(line,1,5)='ERROR' then cnt2+1;
			 if substr(line,1,7)='WARNING' then cnt3+1;
			 if index(line,'uninitialized') then cnt4+1;
			 if index(line,'MERGE statement has more than') then cnt5+1;
			 if index(line,'values have been converted') then cnt6+1;
			 if index(line,'Note: Missing') then cnt7+1;
			 if index(line,'Note: Invalid argument') then cnt8+1;
			 if index(line,'W.D format was too small') then cnt9+1;
			 if index(line,'has 0 observations') then cnt10+1;
			 if index(line,'variables not in') then cnt11+1;
			 if index(line,'variables have conflicting') then cnt12+1;
			 if index(line,'unequal') then cnt13+1;
			 if index(line,'Division by zero detected') then cnt14+1;
			 if index(line,'operations could not be performed') then cnt15+1;
			 if index(line,'duplicate key values were deleted') then cnt16+1;
		 run;

		 proc univariate data=files noprint;
			 by filenm;
			 var cnt1-cnt16;
			 output out=stat1 max=max1-max16;
		 run;	

		 proc transpose data=stat1 out=stat2(where=(col1>0));
			 by filenm;
			 var max1-max16;
		 run;

		 data final;
		 set %if &i>1 %then %do; final %end; stat2;
			 %if &i=&totfile %then %do;
				 length desc $100.;
				 if lowcase(_name_)='max1' then desc='fatal';
				 if lowcase(_name_)='max2' then desc='ERROR';
				 if lowcase(_name_)='max3' then desc='WARNING:';
				 if lowcase(_name_)='max4' then desc='uninitialized';
				 if lowcase(_name_)='max5' then
				 desc='Merge statement has more than one data set with repeats
				 of BY values';
				 if lowcase(_name_)='max6' then
				 desc='values have been converted';
				 if lowcase(_name_)='max7' then desc='Note: Missing';
				 if lowcase(_name_)='max8' then desc='Note: Invalid argument';
				 if lowcase(_name_)='max9' then desc='W.D format was too small';
				 if lowcase(_name_)='max10' then desc='has 0 observations';
				 if lowcase(_name_)='max11' then desc='variables not in';
				 if lowcase(_name_)='max12' then
				 desc='variables have conflicting attributes';
				 if lowcase(_name_)='max13' then desc='unequal';
				 if lowcase(_name_)='max14' then
				 desc='Division by zero detected';
				 if lowcase(_name_)='max15' then
				 desc='Mathematical operation could not be performed';
				 if lowcase(_name_)='max16' then
				 desc='observations with duplicate key values were deleted';
				 drop _name_ _label_;
			 %end;
		 run;
	%end;

	** Get the total number of occurrences of unwanted messages **;
	data _null_;
		set final nobs=last;
		if last then call symput('totobs',trim(left(put(_n_,8.))));
	run;

	** Final output **;
	ods listing close;
	ods noresults;
	ods html file="&path\scanlog.html";
	title1 "Summary of Log Files";
	title2 "&path folder";

	%if &totobs=0 %then %do;
		data _null_;
		file print;
		put "============================";
		put "*** SCANLOG SUCCESSFUL ***";
		put "*** NO BAD GUYS!!! FOUND ***";
		put "============================";
		run;
	%end;
	%else %do;
	proc report data=final headline headskip split='|' missing nowd;
		columns filenm col1 desc;
		define filenm / order order=data
		style(column)=[cellwidth=1.5in]
		style(header)=[just=left] 'File';
		define col1 / style(column)=[cellwidth=1in]
		center 'n' format=3.;
		define desc / style(column)=[cellwidth=5.5in]
		style(header)=[just=left] 'Description';
		compute before filenm;
		line ' ';
		endcomp;
	run;
	%end;
%mend scanlog;

