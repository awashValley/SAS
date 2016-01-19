
* read Excel file into SAS. ;
 proc import datafile="C:...\myfile.xlsx"
              out     =work.mySasData
              dbms    =xlsx replace;
              sheet   ="sheet_1"; 
              getnames=YES;
 run;

* define file name as a macro variable. ;
%let dlbIn = "C:\...";
  
proc contents data=&dlbIn;
run;
