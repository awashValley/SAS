


/*******************************************************************************
  Read raw csv files.
*******************************************************************************/


* Suppress ODS results. ;
ods results off;

* Get the list of available csv files. ;
%let dir =%str(&datapath.\Indata\&dataVers);

filename dirlist pipe "dir /b ""&dir.\*.csv"" ";

data work.dirlist;
  infile dirlist dsd dlm=",";
  length filename $ 1000;
  input filename $;
run;

filename dirlist;

* Create an empty dataset, used for later data concatenation. ;
*   Reset character variable lengths, formats, and informats. ;
proc sql noprint;
  select filename into: ff_name
  from work.dirlist (obs=1);
quit;

filename ff "&dir.\&ff_name";
proc import datafile     =ff
                out      =work.sample
                dbms     =csv replace;             
                getnames =YES;
run;
filename ff;

proc sql;
  select name into :names separated by ' '
  from dictionary.columns 
  where     upcase(libname) ='WORK' 
        and upcase(memname) ='SAMPLE' 
        and type            ='char'
  ;
quit;

data work.combined;
  length   &names $100;
  format   &names $100.;
  informat &names $100.;
  set work.sample;
  stop;
run;

* Import and combine the raw csv files. ;
%macro readRawData(filename=);

  proc import datafile ="&dir.\&filename"    
                out      =work.one
                dbms     =csv replace;             
                getnames =YES;
  run;

  data work.combined;
    set work.combined work.one;
  run;

%mend readRawData;

data work.code;
  set work.dirlist;
  length code $ 1000;
  code =cats('%readRawData(filename=', filename, ');');
  call execute(code);
run;

* Delete temporary dataset(s). ;
proc datasets library=work;
  delete
    dirlist code 
    one sample;
run;
quit;
