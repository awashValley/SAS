
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

/* [Tue, 04OCT2016]. Separate values of macro variable by quotation. */
   PROC SQL NOPRINT;
     SELECT usubjid into :lst_usubjid SEPARATED BY '" "'
     FROM work.test1;
   RUN;

   /* Keep only those selected subjects in TEST2 dataset. */
   PROC SQL NOPRINT;
     CREATE TABLE work.test2 AS  
     SELECT *
     FROM work.test1
     WHERE usubjid IN("&lst_usubjid.")   
     ;
  QUIT;

/* Count number of raw/study datasets available in RAWDATA folder. */
  LIBNAME rawdat "&root_path./VALIDATION/Test Data/Rawdata";
  proc sql noprint; 
    select count(*) into :cnt_ds 
    from dictionary.tables 
    where libname=%upcase("rawdat"); 
  quit;  
  
 /* [Wed, 26OCT2016]. Number of variables in SAS dataset. */
 proc sql noprint;
  select nvar into :num_vars 
  from dictionary.tables
  where libname='SASHELP' and 
        memname='CLASS';
quit;

/* [12-Jan-2017]. Usage of INTO statement */
   PROC SQL NOPRINT;
      SELECT distinct(output_sheet),
             count(distinct(output_sheet))
      INTO   :output_sheets separated by ' ',
             :n_output_sheets
      FROM work.specs_input2
      WHERE listing_name = "&listing_name."
      ;
    QUIT; 

/* [26-Jan-2017]. Selecting All Observations When Any Observation Is of Interest */
/*                 SOURCE: http://support.sas.com/resources/papers/proceedings12/252-2012.pdf */
PROC SQL NOPRINT;
  CREATE TABLE work.ABD_4 AS
  SELECT *
  FROM work.ABD_3
  WHERE subjid IN (SELECT DISTINCT subjid 
                   FROM work.ABD_3 
                   WHERE UPCASE(src)="SAE" )
  ;
QUIT;

/* [07-Feb-2017]. Powerful application of sub-query. */
/* - Get only interesting code lists.                */
PROC SQL NOPRINT;
  CREATE TABLE work.codelist AS
  SELECT *
  FROM lib_data.codelist  
  WHERE code IN(SELECT DISTINCT eventtyp
                FROM work.lab
               ) 
  ;
QUIT;

/* [07-Feb-2017]. Number of records per group (e.g., subjid). */
PROC SQL NOPRINT;
  CREATE TABLE count_labsheet AS
  SELECT subjid, count(subjid) AS count
  FROM work.labsheet_Orig
  GROUP BY subjid
  ORDER BY subjid;
  ;
QUIT;

/* [06-Apr-2017]. Add Suffix to all variables in dataset. */
proc sql;
select cat(name, ' = ', cats(name, '_3mo' )) into :renstr separated by ' ' from
dictionary.columns where libname = 'WORK' and memname='FMIN';
quit;

data new;
set fmin (rename = (&renstr));
run;

/* [08-May-2017]. Flag subjects with multiple records. This is used for a study where subjects had a booster trt at activity=90. */
/* To see the structure of the source dataset work.rndalloc_orig, check this screenshot "flag subjects with multiple records_booster.png" in gitHab. */
DATA work.rndalloc_orig;
  SET rawdata.rndalloc (KEEP = pid activity rnd_id);
RUN;

/* ASSUMPTION: The booster teatment was given at Activity=90. */
PROC SQL NOPRINT;
  CREATE TABLE work.rndalloc AS 
  SELECT *, COUNT(*) AS count
  FROM work.rndalloc_orig
  GROUP BY pid;
QUIT;

PROC SORT DATA=work.rndalloc; BY pid; RUN;

DATA work.rndalloc;
  LENGTH flg_booster $ 2;
  SET work.rndalloc;
  BY pid;
  
  IF count = 2 THEN flg_booster = 'Y';
RUN;
  
DATA work.rndalloc;
  SET work.rndalloc (WHERE = (activity NE 90));    /* Remove a record at visit=90 since we're interested with the other rnd_id. */
RUN;

/* [Mon, 29-May-2017]. Change variable length. */
PROC SQL NOPRINT;
  CREATE TABLE work.rando1 AS
  SELECT A.subjid, B.grp_let AS armcd FORMAT $200. LENGTH 200
  FROM work.rnd_ctrl A LEFT JOIN work._rando B
  ON A.rnd_itt = B.rnd_id;
QUIT;

