*------------------------------------------------------------------------------;
* Define pathname for log file.                                                ;
*------------------------------------------------------------------------------;

filename logout "&olog.\&progname..log";
filename lstout "&olog.\&progname..lst";

proc printto log=logout print=lstout new;
run;

/*proc printto log="&path.\mylog.log" new;
run;*/


*------------------------------------------------------------------------------;
* Create output of log file.                                                   ;
*------------------------------------------------------------------------------;
/*proc printto log=log;
run;*/

proc printto log=log print=print;
run;

filename logout;
filename lstout;

/* Source: http://support.sas.com/kb/32/110.html */
options dtreset fullstimer;

%let SAS_ListingDateTimeStamp   = SAS_Listing_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let ListingOutFile  = C:\temp\test\&SAS_ListingDateTimeStamp..txt;
ods listing file="&ListingOutFile";

%let SAS_LogDateTimeStamp   = SAS_Log_%sysfunc(putn(%sysfunc(date()),yymmdd10.))__%sysfunc(translate(%sysfunc(putn(%sysfunc(time()),timeampm12.)),.,:));
%let LogOutFile  = C:\temp\test\&SAS_LogDateTimeStamp..txt;
filename logfile "&LogOutFile";

proc printto log=logfile;
run;
