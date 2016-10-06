
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
