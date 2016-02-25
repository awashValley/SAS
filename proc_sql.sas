
* How to get row numbers in SAS proc sql. ;
  PROC sql;
    SELECT *, monotonic() as obs_count
      FROM &dlbIn
    WHERE calculated obs_count=100;
  QUIT;
  
  * OR - SAS data statement can also be used. ;
  DATA dset;
    SET &dlbn;
    IF _n_ = &seed;
  RUN;

 * the option 'separated by'. ;
 proc sql noprint;
   select distinct name into: val&i separated by " "
      from customer(where=(sqn=&i));
 quit;
 
 * create sas data set;
 proc sql noprint;
  create table work.contents as
  select distinct memname
  from contents;
 quit;
 
 * [25FEB2016] Multiple SELECT. ;
   proc sql noprint;
     select count(*)
     into :numberofrecords
     from work.cntlfmt;

     select count(distinct(fmtname))
     into :numberofformats
     from work.cntlfmt;

     select label
     into :longestlabel
     from work.cntlfmt
     having length(label) = max(length(label));
  quit;
