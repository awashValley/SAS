proc export data=mydata outfile='c:\dissertation\mydata.xlsx' dbms = xlsx replace;
run;

/* Export part of dataset */
proc export data=WORK.one (OBS=5) outfile="&path./test.xlsx" 
                        dbms = xlsx replace;
run;
