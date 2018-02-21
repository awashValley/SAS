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

/* do somthing */

proc printto;
run;

/* [21FEB2018]. Colorized Text in the Log? */
/* source: https://communities.sas.com/t5/SAS-Enterprise-Guide/Colorized-Text-in-the-EG-Log/td-p/251828 */
filename rev1 temp;
%log4sas();
%log4sas_appender(testout, "FileRefAppender", 'fileref=rev1');
%log4sas_logger(logger, 'level=trace appender-ref=(testout)');

%log4sas_info(logger,"Test INFO message");
%log4sas_debug(logger,"Test DEBUG message");
%log4sas_trace(logger,"Test TRACE message");
%log4sas_warn(logger,"Test WARNING message");
%log4sas_error(logger,"Test ERROR message");
%log4sas_fatal(logger,"Test FATAL message");
