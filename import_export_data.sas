
* read Excel file into SAS. ;
 proc import datafile="C:...\myfile.xlsx"
              out     =work.mySasData
              dbms    =xlsx replace;
              sheet   ="sheet_1"; 
              getnames=YES;
 run;
 
* [23Feb2016] read Excel file into SAS. ;
  proc import datafile ="C:...\myfile.xlsx"
              out      =work.mySasData
              dbms     =dlm replace;
              delimiter=",";              
              getnames =YES;
  run;

* define file name as a macro variable. ;
%let dlbIn = "C:\...";
  
proc contents data=&dlbIn;
run;


* [08MAR2016] read text file using macro variable. ;
  libname  input  "&rawfolder" access=readonly;
  filename readin "&rawfolder\&rawinput";

  proc import datafile=readin 
              out=work.raw1 
              dbms=dlm replace;
    delimiter = '09'x; 
    getnames = yes;
  run;

/* [Fri, 22-Sep-2017]. Import TXT file format. */
FILENAME src  "path" TERMSTR=CRLF LRECL=3276;    /* CRLF for carriage return */
FILENAME src  "path" TERMSTR=LF LRECL=3276;

DATA  WORK._macvar;
	%LET _EFIERR_ = 0;
	INFILE src  DELIMITER= &dlm  MISSOVER DSD lrecl=32767 OBS=1;
	INFORMAT var1-var25  $200. ;
	FORMAT var1-var25 $200. ;
	INPUT var1-var25;
	IF _ERROR_ then call symputx('_EFIERR_',1); 
RUN;

/* [27-Feb-2018]. Remove blank columns imported from Excel using RANGE option in PROC IMPORT. */
proc import out=work._test DATAFILE= "&xls_smapping." DBMS=xls REPLACE;          
	range = "&tabIn.$A:K";       /* The RANGE option allows us to remove blank columns. */
	getnames = YES; 
run;
