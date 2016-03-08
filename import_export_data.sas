
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
    getnames = YES;
  run;
