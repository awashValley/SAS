
/* [Tue 31MAY2016]. Create and store formats for treatment groups. */
  proc sql noprint;
    create table fmtTable as
    select distinct treatment 
    from work.analysis_ds;
  quit;

  data fmtTable (drop= treatment);
    length start 8
           fmtname $15
           label $15
           ;
    set fmtTable;

    start = _n_;
    fmtname = 'fmtTrt';
    label = cat("Group ", _n_);
  run; 

  proc format cntlin=work.fmtTable library=work;
  run;
