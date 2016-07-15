
* [Tue 31MAY2016]. Create and store formats for treatment groups. ;
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


* [Fri 15JUL2016]. Append asterisk for significant mean values. ;
* Reference: http://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a002473467.htm ;
  proc format;
    picture myage
      low - 13 = '00*'
      15 - high = '00*';
  run;

  data work.test;
    set sashelp.class;
    format age myage.;
  run;
