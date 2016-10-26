filename test "&file_path/test.XLS";


proc import datafile= "test"
  out=&check (keep=var1 var2)
  dbms=xls
  replace;
  sheet="Standard Checks";
run;
