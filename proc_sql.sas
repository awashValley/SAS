
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
  
* [Thur 17Mar2016]. Add a new variable. ;
  proc sql noprint;
    create table myTable as
    select var1, var2, "hello" as var3_fromScratch
    from work.test;
  quit;

* [Fri 01APR2016]. Get the first obs. ;
  proc sql noprint;
    select filename into: first_file
    from work.dirlist (obs=1);
  quit;
  
  
* [Thur 21JUL2016]. Update values in a dataset. ;
  proc sql;
    update work.demog set unique='34343' where
    unique='20202';
  quit;
  
* [Thur 01SEP2016]. Insert a new row in empty SAS dataset. ;
  PROC SQL NOPRINT;
  INSERT INTO outdt.suppae_pre
  SET 
    studyid  =" ", 
    rdomain  =" ",
    usubjid  =" ",
    idvar    =" ",
    idvarval =" ",
    qnam     ="AEPOSTVC", 
    qlabel   =" ",
    qval     =" ",
    qorig    =" ",
    qeval    =" ";
  QUIT;

/* [Tue, 20SEP2016]: Count number of datasets available in a file. */
LIBNAME rawdat "path..." access=readonly;

PROC SQL NOPRINT;
  SELECT memname into :ds_list SEPARATED BY ' ' 
  FROM dictionary.tables 
  WHERE LIBNAME = "RAWDAT";
QUIT;

/* [Mon, 26SEP2016]. Get column names for your datset.  */

  /* Check QNAM and USUBJID */
  LIBNAME inpt2 "&file_path";

  proc sql noprint;
    select name into :col_names separated by ' '
    from dictionary.columns
    where libname = "INPT2" and 
          memname = "MYDATA"
    ;
  quit;


