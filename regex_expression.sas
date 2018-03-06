* [MON 22AUG2016]. Regular expression using PRXMATCH. ;
  IF PRXMATCH("/^\d\d\d\d-\d\d-\d\d/",&refdate) AND 
     PRXMATCH("/^\d\d\d\d-\d\d-\d\d/",&date)
  THEN DO;

    /* something to be done */

  END;
  ELSE DO;
    /* something to be done */
  END;

/* Regular expression example. */
/* SOURCE: http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a002295969.htm */

data test;
  text = "lib1.xyz=lib2.abc blah blahh lib3.fgh=lib4.ijk"; 
  ptnID = prxparse('/(\w+)\.(\w+)/');     /* since dot is a special character, you need to escape it. */
  
  IF PRXMATCH(ptnID, text) THEN 
  DO;
    call prxposn(ptnID, 1, position, length);
    first_wrd = substr(text, position, length);
    output;
    
    call prxposn(ptnID, 2, position, length);
    second_wrd = substr(text, position, length);
    output;
  END;
  
run;

data _null_;
   patternID = prxparse('/(\d\d):(\d\d)(am|pm)/'); 
   text = 'The time is 09:56am.';

   if prxmatch(patternID, text) then do;
      call prxposn(patternID, 1, position, length);
      hour = substr(text, position, length);
      call prxposn(patternID, 2, position, length);
      minute = substr(text, position, length);
      call prxposn(patternID, 3, position, length);
      ampm = substr(text, position, length);

      put hour= minute= ampm=;
      put text=;
   end;
run;

/* [Wed, 26-Apr-2017]. Find a string using Datastep. */
DATA work.subset (DROP = pid);
  LENGTH subjid subset $ 200;
  SET rawdata.pid_schd (KEEP = pid sch_desc);
  
  subjid = PUT(pid,z6.); 
  
  subset = SUBSTR(sch_desc, FIND(sch_desc, "PART "));     /* The value of sch_desc is something like 'Workbook 1 (Schedule 0,1,6) PART B' and 'Workbook 3 (Schedule 0,6) PART A'. */
RUN;

/* [Thur, 20170511]. Use FIND function to find patterns. */
DATA work.test;
  SET work.source;
  
  IF      FIND(UPCASE(STRIP(tradname)), "VARIVAX") THEN ecroute = "SC";
  ELSE IF FIND(UPCASE(STRIP(tradname)), "PREVNAR") THEN ecroute = "IM";
  ELSE IF FIND(UPCASE(STRIP(tradname)), "HAVRIX")  THEN ecroute = "IM";
RUN;

/* [01-Aug-2017]. Drop/Keep variables using pattern matching (e.g., LIKE, colon wildcard).  */
%macro drop_vars(dsin = );
/* GENERAL: Get list of unnessary variables in source dataset CM. */
   
   %global droplist;
   %let droplist = ;
   
   proc contents data=&dsin. out=work.contents(keep=name) noprint ; run;
   
   proc sql noprint ;
      select name into :droplist separated by ' '
      from work.contents
      where upcase(name) like '%^_FRN' escape '^' OR 
            upcase(name) like '%^_SRN' escape '^' OR 
            upcase(name) like '%^_IRN' escape '^' OR 
            upcase(name) like '%^_CRN' escape '^' OR 
            upcase(name) like '%^_EDT' escape '^' OR 
            upcase(name) like '%^_CTX' escape '^' OR 
            upcase(name) like '%^_ND'  escape '^'     
      ;
   quit;
   
   %put droplist: &droplist;
   
%mend drop_vars;


/******************
** pp 254/255    **
*******************/

/* Read source dataset. */
data cm;
  set rawdata.cm (keep=CMINDCPRSP CMINDCGEN CMINDCLOC CMINDCOTH 
                       /*CMMHNO: CMAENO:*/
                       CMMHNO1-CMMHNO6 CMAENO1-CMAENO6);
run;

%drop_vars(dsin = work.cm);

/* [06-Mar-2018]. Use prxmatch to match strings ending in a certain word */
/* - source: http://support.sas.com/kb/38/719.html */
/* Apply to test dataset. */
	data test2;
		length length 8 
			   format $ 20
			   ;
		set test;
		
		/* Derive length variable. */
		if      strip(type) = 'C' then do;
			if      prxmatch("m/TEST$/oi", strip(name)) > 0 then length = 40;
			else if prxmatch("m/CD$/oi",   strip(name)) > 0 then length = 10;
			else                                   length = 200;
		end;
		else if strip(type) = 'N' then do;
												  length = 8;
		end;
		
		* Define length for user-defined variables. ;
		&len_eShare_vars;
		
		/* Derive format. */
		format = "";
		
		* Define format for user-defined variables. ;
		&fmt_eShare_vars;
	run;
