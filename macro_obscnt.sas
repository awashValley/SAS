**************************************** ;
	** Get number of records in a dataset.   ;
	**************************************** ;
	** ------------------------------------------------------------------------------------------------------------------- ;
	** -- source: http://www.sascommunity.org/wiki/Determining_the_number_of_observations_in_a_SAS_data_set_efficiently    ;
	** ------------------------------------------------------------------------------------------------------------------- ;
	%macro obscnt(dsn);
		%global nobs;           * [Haile, 14-Mar-2018], updated. ;
		%local 
/* 			nobs  */
			dsnid
			;
		%let nobs=.;
		 
		%* Open the data set of interest;
		%let dsnid = %sysfunc(open(&dsn));
		 
		%* If the open was successful get the;
		%* number of observations and CLOSE &dsn;
		%if &dsnid %then %do;
		     %let nobs=%sysfunc(attrn(&dsnid,nlobs));
		     %let rc  =%sysfunc(close(&dsnid));
		%end;
		%else %do;
		     %put Unable to open &dsn - %sysfunc(sysmsg());
		%end;
		 
		%* Return the number of observations;
/* 		&nobs; */         * [Haile, 14-Mar-2018], updated. ;
	%mend obscnt;
