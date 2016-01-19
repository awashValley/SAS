libname idb "C:\.." access=readonly;

%macro getLongestVal(ds=, var=);

  proc sql noprint;
    create table work.results as
    select distinct "&var." as variable, &var. as value
    from &ds.
    having length(&var.) = max(length(&var.))
    ;
  quit;

  data work.allresults;
    set work.allresults
        work.results;
  run;

%mend getLongestVal;

* Create empty data set. ;
data work.allresults;
  length variable $ 40 value $ 8000; 
  call missing(of _all_);     * to set the variable value to missing; 
  if 0;   * to remove SAS default empty row;
run;

proc contents data=idb._all_
              out =work.contents (where = (type = 2)
			                      keep  = memname name type length)
			  noprint;
run;

data work.code;
  length code $ 200;
  set work.contents;
  code = cats('%getLongestVal(ds=idb.', memname, ', var=', name, ');');
  call execute(code);   * to call and run the macro for each data set per variable name;
run;
