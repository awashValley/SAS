*------------------------------------------------------------------------------;
* Define pathname for log file.                                                ;
*------------------------------------------------------------------------------;

filename logout "&olog.\&progname..log";
filename lstout "&olog.\&progname..lst";

proc printto log=logout print=lstout;
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
