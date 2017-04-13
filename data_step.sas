
* [15JAN2016]. Initialize a variable. ;
   data random;
     length seedLs $ 20;
     retain seedLs;
		  
     /* DO z JOB */
   run;
  
  
* [15JAN2016]. Concatenate variable values within a loop. ;
   data random;
     * initialize the variable (to be concatenated). ;
     length seedLs $ 20;
     retain seedLs;

     %do i=1 %to &max;
       random_int = int(ranuni(&seed) * &nRec + 0);
       seedLs = catx(" ", random_int, seedLs);
     %end;
     
     * create a macro variable. ;
     call symput("seedLs", seedLs);
   run;
   
   /* REMARK: You can't create a macro variable and with CALL SYMPUT and use it in the same DATA step
   	      because SAS doesn't assign a value to the macro variable until the DATA step excutes. */
   	      
   	      
* [27JAN2016]. read data using macro variable. ;
  %let block =%str(survival\data);
  libname dlbIn "&mpath.\&block";  

  proc print data=dlbIn.infecdd(obs=5);
  run; 
  
* [27JAN2016]. remove all formats, labels, informats. ;
  proc datasets lib=<your library> memtype=data nolist;
    modify <your dataset>; 
      attrib _all_ label=' '; 
      attrib _all_ format=;
      attrib _all_ informat=;
  run;
  
 * [23FEB2016] Create data set with missing values. ;
   data work.test;
     length a $ 20
            b 8
            c 3
	    d $ 40
	    e 8;
    format a $10.;
    call missing(of _all_);
  run;
  
 * [24FEB2016] Create a variable with missing value. ;
   varTest=.c;

 * [25FEB2016] Create data set without CARDS. ;
   data work.results;
     length test result $200;

     test = "Number of records"; 
     result = strip("&numberofrecords."); 
     output;

     test = "Number of formats"; 
     result = strip("&numberofformats."); 
     output;

     test = "Longest label"; 
     result = strip("&longestlabel."); 
     output;
    run;
    
 * [MON 15Mar2016 10:15]. Reshape long to wide. ;
   proc sort data=work.long out=work.long_sort;
     by id;
   run;

   data wide1;
     set long_sort;
     by id;

     keep id treatment resp1 - resp12;
     retain resp1 - resp12;

     array aresp(1:12) resp1 - resp12;

     if first.id then
     do;
       do i = 1 to 12;
         aresp(i) =.;
       end;
     end;

     aresp(time) =resp;

     if last.id then output;
   run;
   
* [Thur 17Mar2016]. Get smallest values among variables. ;
  DATA two;
    SET one;
    ARRAY nums [*] a b c d e;
    lowest=MIN(a, b, c, d, e);
    DO i=1 TO DIM(nums);
      IF nums[i]=lowest THEN lowestvar=VNAME(nums[i]);
    END;
  RUN;


* [Fri 01Apr2016]. Create empty data set (source: Raymond Ebben - www.info-net.nl/create-an-empty-dataset.html). ;
  data work.combined;
    set work.sample;
    /* Make sure that no records will be outputted */
    stop;
  run;
  
* [Mon 04Apr2016]. Get empty datasets.;
  proc sql;
    select memname into :dellist separated by ' ' 
    from dictionary.tables 
    where libname='WORK' and nobs=0;
  quit;
  
* [Mon 04Apr2016]. Number of observations in a dataset (or if it is empty). ;
  proc sql noprint;
    select count(*) into :obs 
    from work.logres;
  quit;
  
* [Mon 04Apr2016]. SYMGET function. Don't forget to use quotation. ;
  data work.test;
    length Type LogRes $10;
    set work.test;
    Type = "&cov_type";
    LogRes =symget(strip('logRes'));
  run;
  
* [Thur 07Apr2016]. Create missing variable. ;
  data work.test;
    set work.orig;
    call missing(exclusion);
  run;
  
* [Fri 08Apr2016]. Create a variable with alphabet characters. ;
  data work.out1;
    set work.out;

    length v_i $1.;

    by &group;
    if first.&group then
    do;
      seq + 1;
      v_i = byte(64 + _n_); 
    end;
  run;

* [Wed 01JUNE2016]. find and replace using TRANWRD. ;
  data work.log2 (drop =findings);
    set work.log (where = (findings like '%NOTE%' or
                           findings like '%WARN%' or
                           findings like '%ERR%'));

    findings2 =tranwrd(findings, 'NOTE: ', ' ');
  run;

* [Thur 02JUN2016]. Calculate dates. ;
  data work.test;
    start = "07JAN2016"d;
    end = start + 180;
    put end date9.;
  run;
  
 * [06JUN2016]. Define footnote using data step. ;
   data _null_;
      length code $100;
      retain code;
      set ds_excluded;
    
      by id;

      if first.id then
      do;
        code = catx(" ", 
                    cats("footnote", strip(put(seq, best.))),
                    cats("Id", "=", " ", put(id, best.)),
                    cats("Interval", "="));
      end;

      code = catx(" ", code, put(interval, best.));

      if not last.id then
      do;
        code = cats(code, ",");
      end;
      else 
      do;
        code = cats(code, ";");
        output;
      end;

      call execute(code);
    run;
    
  * [06JUN2016]. Create sequence starting from "2". ;
    data work.test (keep= var1 var2 seq2);
      length var1 var2 seq2 8;
      retain seq2;
      set work.test;
      
      by var1;
      if first.var1 then 
      do;
        seq+1;
        seq2 = seq + 1;
      end;
    run;
    
  * [06OCT2016]. Another sequence example. ;
    DATA work.test(DROP = tempseq);
       SET work.test;
       BY sort_vars;
      
       tempseq + 1;
       IF FIRST.usubjid THEN tempseq = 1;
       aeseq = tempseq;
     RUN;
    
  * [08JUN2016]. Create SAS dataset from scratch. ;
    data work.test;
      length parm $20 sex $1 _treatment Adjp 8;

      %do i=1 %to &cnt_sex;
               
        %let sex_i = %scan(&grps_sex, &i, %str( )); 
        parm = symget('label_parameter');
        
        sex  ="&sex_i";
        _treatment = 1; 
        Adjp       = 1.0000; 

        output;
        
      %end;
    run;
    
* [22JUN2016]. Display Error/Warning/Note message to the log. ;
   data _null_;
     put "ERR" "OR: you're in problem.";
   run;
   
* [24JUN2016]. Looping. ;
  %MACRO step1 ;    
  %MEND step1;     
  /*Do the same for step2 through step20*/
  DATA _NULL_;
    DO mani = 2 to 20;
      CALL EXECUTE('%MACRO step'||STRIP(mani)||'; %MEND step'||STRIP(mani)||';');
    END;
  RUN;
  
* [28JUN2016]. Assign missing value in DATALINES. ;
  DATA code;
    LENGTH dateRaw $9 dateIso $11;
    INPUT dateRaw $ dateIso $;
  
    *dateIso = " ";  /* NOT ALLOWED */
  
    DATALINES;
    10DEC2016 .
    ;
  RUN;
  
  
* [TUE 12JUL2016]. Importe Excel file. ;
* - The xlsx in the LIBNAME statement indicates SAS shouldn't look for regular SAS datasets but for xlsx in this case. ;
  LIBNAME mylib xlsx "path/to/file.xlsx";
  
  DATA work.test;
     LENGTH ...;
     INFILE mylib;
     INPUT ...;
  RUN;
  
  
* [WED 13JUL2016]. Using IN operator. ;
  DATA test;
    SET orig;
    
    IF UPCASE(table) IN("A" "B" "C" "D") THEN OUTPUT;
  RUN;


* [MON 18JUL2016]. Duplicate data. ;
* Reference: http://stackoverflow.com/questions/10286523/copy-and-pasting-rows-into-a-sas-dataset ;
  data work.have;
    a=1;b=2;c=3;
  run;

  data work.want;
    set work.have;
     output;

    if a=1 then output; /* Again */
  run;
  
* [WED 14SEP2016]. Use of <EOF> command. ;
  DATA _NULL_;
    SET work.test END=eof;
 
    IF eof THEN CALL SYMPUTX('nrows',PUT(_N_,8.));              
  RUN;
  
 * [Thur, 29SEP2016]. Attribute statement used for creating an empty SAS dataset. ;
   DATA work.mapped_co;
     ATTRIB studyid  LENGTH=$200 label='Study Identifier' 
            domain   LENGTH=$200 label='Domain Abbreviation' 
            rdomain  LENGTH=$200 label='Related Domain Abbreviation' 
            usubjid  LENGTH=$200 label='Unique Subject Identifier' 
            coseq    LENGTH=8    label='Sequence Number' 
            idvar    LENGTH=$200 label='Identifying Variable' 
            idvarval LENGTH=$200 label='Identifying Variable Value'          
            coval1   LENGTH=$200 label='Comment 1'          
            coval2   LENGTH=$200 label='Comment 2'
            ;
  
     CALL MISSING(OF _ALL_);
   RUN;

/* [Fri, 30SEP2016]. How to Check, if the variable exists in the SAS dataset or not? */
/* SOURCE:           http://studysas.blogspot.co.uk/2009/04/how-to-check-if-variable-exists-in-sas.html */
  DATA _null_;
    dset = OPEN('sashelp.class');
    CALL SYMPUT('chk_var', varnum(dset, 'age'));
  RUN; 
  
  %PUT >>> chk_var: &chk_var;
  
/* [Wed, 05OCT2016]. Obtain the number of records in dataset.  */
   DATA _NULL_;
     SET sashelp.class END=LAST;
  
     IF LAST THEN CALL SYMPUT('num_obs', _N_);
   RUN;

/* [Fri, 04NOV2016]. Add to all records, except for the last one */
  DATA &attr_dsin.;
    LENGTH inxls_vars $200;
    SET &attr_dsin. END = LAST ;
    
    inxls_vars = strip(name) || "   " || "*" || "   " || strip(format) || strip(length); 
    IF NOT LAST THEN inxls_vars = STRIP(inxls_vars) || "   " || "@";
  RUN;
  
/* [Sun, 20161106]. Convert date to string */
DATA work.test (DROP = _var3_dt);
  LENGTH var1 var2 8 var3_dt $20;
  SET work.test (RENAME = (var3_dt = _var3_dt) );
  
  var3_dt = PUT(_var3_dt, datetime.);
RUN;

/* [20161107]. SAS convert string into datetime */
/* SOURCE: http://stackoverflow.com/questions/15544981/sas-convert-string-into-datetime */
data have ;
  datestring = "01-Oct-2012 12:23:43.324" ;
run ;

data want ;
  set have ;

  dt = input(scan(datestring,1,' '),??date11.) ;
  tm = input(scan(datestring,2,' '),??time14.) ;
  dttm = dhms(dt,0,0,tm) ;

  format dt date9. tm time14.3 dttm datetime24.3 ;
run ;

/* Get subjid who has visited twice (10, 20) */
proc sort data=inpt_ae;
  by subjid;
run;

DATA target.inpt_ae;
  SET target.inpt_ae (WHERE = (visitnum IN(10 20)) );
  
  BY subjid;
  
  IF (first.subjid AND NOT last.subjid) OR
     (not first.subjid AND last.subjid);
RUN;

/* Reading Raw Data with the INPUT Statement */
   > http://support.sas.com/documentation/cdl/en/lrcon/62955/HTML/default/viewer.htm#a003209907.htm

/* [12-Jan-2017]. The power of PUT statement */
DATA _null_;
  SET work.specs_parameters(WHERE=(listing_name = "&listing_name." AND
                                  (name="&listing_name." OR name = "&output_sheet." OR missing(name)) AND
                                   type = 'LISTING'));
  IF _N_ = 1 THEN PUT '### Specs PARAMETERS:';
  PUT 2*'#' @ 4 parameter @20 value;
  call symputx(parameter,value);
RUN;

/* [15-Feb-2017]. Compare two columns of the variable in two same dataset, and identify the changes. */
/* - Enhancement: check if this can be done using PROC SQL... */
PROC SORT DATA=target.crf_page_all_old OUT=crf_page_all_old;
  BY visitnum panelcd eventtyp;
RUN;

PROC SORT DATA=target.crf_page_all OUT=crf_page_all;
  BY visitnum panelcd eventtyp;
RUN;

DATA work.qwe2 (KEEP = visitnum panelcd eventtyp);
  /*LENGTH flg_eventtyp $10;*/  /* Not sure how to calculate the flag... */
  MERGE crf_page_all_old (IN=a) crf_page_all (IN=b);
  
  BY visitnum panelcd eventtyp;   /* unique records */
  IF a+b < 2 THEN OUTPUT;
RUN;

/* [22-Feb-2017]. Retain baseline value. */
proc sort data=work.bw;
  by animal;
run;

data work.bw;
  set work.bw;
  by animal;
  
  if first.animal then base=resp;
  
  retain base;
run;


/* [02-Mar-2017]. Concatenate multiple rows in dataset per group. */
DATA work.all_vars_3;
  LENGTH keep_vars $200;
  RETAIN keep_vars;
  
  SET work.all_vars_2;
  
  BY dataset;
  
  IF first.dataset THEN keep_vars = CATS(variable);
  ELSE keep_vars = CATX(' ', keep_vars, variable);
  
  IF last.dataset THEN OUTPUT;
RUN;

/* [Thur, 09-Mar-2017]. Calculate age from date difference. */
DATA work.demog;
  SET work.demog;
  
  /* Calculate Age. */
  IF LENGTH(rficdtc) >= 10 AND LENGTH(brthdtc) >=10 THEN age = FLOOR((INPUT(SUBSTR(rficdtc,1,10), is8601da.) - INPUT(SUBSTR(brthdtc,1,10), is8601da.))/365.25);
  ELSE age = .;
  
  /* Calculate Ageu. */
  IF NOT MISSING(age) THEN ageu = "YEARS";
  ELSE ageu = " ";
RUN;

/* [Mon, 13-Mar-2017]. Compare SAS dates. */
DATA work.test;
  SET work.test;
  IF NOT MISSING(dthdtc) AND NOT MISSING(rfendtc) AND 
         INPUT(dthdtc, yymmdd10.) < INPUT(rfendtc, yymmdd10.) THEN
  DO;
    rfendtc = dthdtc;
  END; 
RUN;

/* [Fri, 17-Mar-2017]. convert numeric to character. */
/* - Variable visitnum is numeric. */
DATA work.test;
  SET work.source;
  
  eclnkgrp = CATS("V", STRIP(PUT(visitnum, BEST.)), "-", STRIP(ecspid));
RUN;

/* [Fri, 17-Mar-2017]. Remove leading zeros. */
/* - Suppose variable ae_nb could have leading zeros and it's string. */
DATA work.test;
  SET work.source;
  
  xyz = INPUT(ae_nb, BEST.);
RUN;

/* [Thur, 30-Mar-2017]. Calculate Age in YEARS or in MONTHS.  */
DATA test;
  *IF LENGTH(rficdtc) >= 10 AND LENGTH(brthdtc) >=10 THEN age = FLOOR((INPUT(SUBSTR(rficdtc,1,10), is8601da.) - INPUT(SUBSTR(brthdtc,1,10), is8601da.))/365.25);
  *IF LENGTH(rficdtc) >= 10 AND LENGTH(brthdtc) >=10 THEN age = FLOOR((INPUT(SUBSTR(rficdtc,1,10), is8601da.) - INPUT(SUBSTR(brthdtc,1,10), is8601da.))/365.25*12);
  *IF LENGTH(rficdtc) >= 10 AND LENGTH(brthdtc) >=10 THEN age = FLOOR((INPUT(SUBSTR(rficdtc,1,10), is8601da.) - INPUT(SUBSTR(brthdtc,1,10), is8601da.))/7);
  IF LENGTH(rficdtc) >= 10 AND LENGTH(brthdtc) >=10 THEN age = FLOOR((INPUT(SUBSTR(rficdtc,1,10), is8601da.) - INPUT(SUBSTR(brthdtc,1,10), is8601da.)));
  ELSE age = .;
  *IF NOT(MISSING(age)) THEN ageu = 'YEARS';
  *IF NOT(MISSING(age)) THEN ageu = 'MONTHS';
  *IF NOT(MISSING(age)) THEN ageu = 'WEEKS';
  IF NOT(MISSING(age)) THEN ageu = 'DAYS';
  ELSE ageu = ' ' ; 
RUN;

/****************************************************
** Derive age category (age_catX, where X=1,2,3).  **
** Refer the screenshot called <age_cat.png>       **
*****************************************************/
DATA work.age_cat (DROP = pid);
  LENGTH domain studyid usubjid agecat1 agecat2 agecat3 $ 200;
  SET rawdata.age_cat (KEEP = pid activity age_cat);
 
  domain = STRIP(SYMGET("domain")); 
  studyid = STRIP(SYMGET("studyNr"));
  usubjid = STRIP(studyid)||'-'||STRIP(PUT(pid,z6.));
  
  IF activity=20 THEN DO;         /* Age category at Time of First Injection. */
    IF      STRIP(age_cat)="1" THEN agecat1 = "< 5 MONTHS";
    ELSE IF STRIP(age_cat)="2" THEN agecat1 = "> = 5 MONTHS";
  END; 
  ELSE IF activity=40 THEN DO;    /* Age category at Time of Second Injection. */
    IF      STRIP(age_cat)="3" THEN agecat2 = "< 5 MONTHS";
    ELSE IF STRIP(age_cat)="4" THEN agecat2 = "> = 5 MONTHS";
  END; 
  ELSE IF activity=60 THEN DO;     /* Age category at Time of Third Injection. */
    IF      STRIP(age_cat)="5" THEN agecat3 = "< 5 MONTHS";
    ELSE IF STRIP(age_cat)="6" THEN agecat3 = "> = 5 MONTHS";
  END; 
RUN;

/* From long-format to wide-format. */
PROC SORT DATA=work.age_cat; BY usubjid activity; RUN;

DATA work.age_cat2 (DROP = activity);
  MERGE work.age_cat (KEEP  = domain studyid usubjid activity agecat1
                      WHERE = (activity=20))
        work.age_cat (KEEP  = domain studyid usubjid activity agecat2
                      WHERE = (activity=40))
        work.age_cat (KEEP  = domain studyid usubjid activity agecat3
                      WHERE = (activity=60));
                      
  BY usubjid;
RUN;


