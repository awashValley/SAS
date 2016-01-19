
/*  ---------------------- */
/*  Check Data Truncation  */
/*     19JAN2016	   */
/*  ---------------------- */
%macro getLongestVal(ds=, var=);

  proc sql noprint;
    create table work.results as
    select distinct upcase("&var.") as variable, &var. as value
    from &ds.
    having length(&var.) = max(length(&var.))
    ;
  quit;

  * Mark the variable with multiple values of the same max length. ;
  data work.results;
    length variable $ 40;
    set work.results (obs=10) nobs=nobs;
	if nobs > 10 then variable = cats(variable, "*");
  run;

  data work.allresults;
    set work.allresults
        work.results;
  run;
%mend getLongestVal;

* Create data set with empty rows. ;
data work.allresults;
  length variable $ 40 value $ 8000; 
  format value $8000.;
  call missing(of _all_);
  if 0;
run;


libname idb "C:\.." access=readonly;
/*proc contents data=idb._all_*/
proc contents data=idb.dm
              out =work.contents (where = (type = 2)
			                      keep  = memname name type length)
			  noprint;
run;

data work.code;
  length code $ 200;
  set work.contents;
  code = cats('%getLongestVal(ds=dlb.', memname, ', var=', name, ');');
/*  if upcase(name) in("DMBTHDT");*/
    call execute(code);
run;
	
