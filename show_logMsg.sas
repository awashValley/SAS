%macro show_logMsg (logIn = );
	/* SAS builtin macro for styling log message. */
	%log4sas();
	%log4sas_logger(msg1, 'level=error');
	%log4sas_logger(msg2, 'level=warn');
	
	/* Collect errors/warnings from log file. */
	data work.log_err work.log_warn;
     	infile  "&logIn" truncover;
		input log_report $200.;
		if index(log_report, 'ERROR:')  > 0 or index(log_report, 'ERR') > 0 then output work.log_err;
		if index(log_report, 'WARNING') > 0 or index(log_report, 'WAR') > 0 then output work.log_warn;
	run;
	
	/* Inform app user about possible errors/warnings. */
	%let nbr_err  =;
	%let nbr_warn =;
	
	/* Regarding errors. */
	%macro check_err;
		proc sql noprint;
		  select count(distinct(log_report)) into :nbr_err
		  from work.log_err
		  ;
		quit;
		
		/* Inform user about errors, if there is any. */
		%if &nbr_err. > 0 %then %do;
			%let err_msg = The Mapping Engine application failed with %str(%sysfunc(strip(&nbr_err.))) errors. Please check the log file located in the ./Logs folder.;
			%log4sas_error(msg1,"&err_msg");
		%end;
	%mend check_err;
	%check_err;
	
	/* Regarding errors. */
	%macro check_warn;
		proc sql noprint;
		  select count(distinct(log_report)) into :nbr_warn
		  from work.log_warn
		  ;
		quit;
		
		/* Inform user about warnings, if there is any. */
		%if &nbr_warn. > 0 %then %do;
			%let warn_msg = The Mapping Engine application runs with %str(%sysfunc(strip(&nbr_warn.))) warnings. Please check the log file located in the ./Logs folder.;
			%log4sas_warn(msg2,"&warn_msg");
		%end;
	%mend check_warn;
	
	/* Run warning detector, if no error is detected. */
	%if &nbr_err. = 0 %then %do;
	  	%check_warn;
	%end;
	
%mend show_logMsg;
