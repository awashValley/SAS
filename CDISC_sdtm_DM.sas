
** Read in SDTM macros **;
FILENAME SDTMMAC "z_path";
%INCLUDE SDTMMAC(ISO_FROM_RAWDATE.SAS);
%INCLUDE SDTMMAC(CALCULATEDAYNO.SAS);

**Define the input folder with LIB_DATA data;
%LET domain  = DM;
%LET studyNr = <z_studyNr>;

%LET insdtm_projNr  = <z_projNr_vendor>;
%LET insdtm_archive = 21MAR2017;

%LET rawdata_projNr  = <z_projNr_source>;
%LET rawdata_studyNr = &studyNr.;
%LET rawdata_archive = 20081209;

LIBNAME insdtm "<...>/&insdtm_projNr./&insdtm_archive.";
                
LIBNAME rawdata "<...>/&rawdata_projNr./STUDIES/&rawdata_studyNr./DATA/&rawdata_archive./CLINICAL/RAW_DATA" access=readonly;   

OPTIONS VARLENCHK = NOWARN YEARCUTOFF=1917 VALIDVARNAME=UPCASE NOFMTERR COMPRESS=YES NOQUOTELENMAX;


DATA work.dm1 (DROP = _race _ethnic);
  LENGTH subjid brthdtc siteid sex race raceor raceoth ethnic $200;
  SET rawdata.demog (RENAME = (race   = _race 
                               ethnic = _ethnic));                    
  
  subjid = PUT(pid,z6.);
  %iso_from_rawdate(outvar=brthdtc, invar=dob_raw);
  siteid = STRIP(UPCASE(center));
  sex = STRIP(UPCASE(sex));

  IF      STRIP(_race) = '3'  THEN raceor = 'ASIAN - CENTRAL / SOUTH ASIAN HERITAGE';
  ELSE IF STRIP(_race) = '9'  THEN raceor = 'WHITE - CAUCASIAN / EUROPEAN HERITAGE';
  ELSE IF STRIP(_race) = '99' THEN raceor = 'OTHER';
  ELSE IF NOT(MISSING(_race)) THEN PUT "WAR" "NING: RACE" _race=;

  IF      STRIP(_race) = '3'  THEN race = 'ASIAN';
  ELSE IF STRIP(_race) = '9'  THEN race = 'WHITE';
  ELSE IF STRIP(_race) = '99' THEN race = 'OTHER';
  ELSE IF NOT(MISSING(_race)) THEN PUT "WAR" "NING: RACE" _race=;
  
  raceoth = STRIP(UPCASE(race_oth));

  IF      STRIP(_ethnic) = '1'  THEN ethnic = 'HISPANIC OR LATINO';
  ELSE IF STRIP(_ethnic) = '2'  THEN ethnic = 'NOT HISPANIC OR LATINO';
  ELSE IF NOT(MISSING(_ethnic)) THEN PUT "WAR" "NING: ETHNIC" _ethnic=;
RUN;

/*get vaccination dates*/
DATA work.vaccprod(KEEP = subjid activity);
  LENGTH subjid $200;
  /*SET rawdata.vaccprod(WHERE=(v_adm = 'Y'));*/
  SET rawdata.vaccprod(WHERE=(vial_typ NE 'N'));
  subjid = PUT(pid,z6.); 
RUN;

DATA work.v_info(KEEP = subjid activity vacdat);
  LENGTH subjid vacdat $200;
  /*SET rawdata.vac_info;*/
  SET rawdata.v_info(WHERE=(v_type = 'VAC' AND NOT MISSING(vaccrdat)));
  subjid = PUT(pid,z6.); 
  %iso_from_rawdate(outvar=vacdat, invar=vaccrdat);
RUN;

DATA work.actdates(KEEP = subjid activity visdat);
  LENGTH subjid visdat $200;
  SET rawdata.actdates;
  subjid = PUT(pid,z6.); 
  %iso_from_rawdate(outvar=visdat, invar=actrdate);
RUN;

PROC sort DATA=work.vaccprod; BY subjid activity; RUN;
PROC sort DATA=work.v_info;   BY subjid activity; RUN;
PROC sort DATA=work.actdates; BY subjid activity; RUN;

DATA work.vacdates;
  MERGE work.vaccprod(IN=a) work.v_info work.actdates;
  BY subjid activity;
  IF a;
RUN;

/*get THE date per visit*/
DATA work.vacdates;
  SET work.vacdates;
  IF NOT(MISSING(vacdat)) THEN date2use = vacdat;
  ELSE date2use = visdat;
RUN;

PROC sort DATA=work.vacdates(WHERE=(NOT(MISSING(date2use)))); 
  BY subjid date2use;
RUN;
DATA work.rfdates(KEEP = subjid rfxstdtc rfxendtc);
  RETAIN rfxstdtc;
  SET work.vacdates;
  BY subjid date2use;   
  IF FIRST.subjid THEN rfxstdtc = date2use;
  IF LAST.subjid THEN DO;
    rfxendtc = date2use;
    OUTPUT;
  END;
RUN;

DATA work.consent;
  LENGTH subjid rficdtc $200;
  SET rawdata.consent;
  subjid = PUT(pid,z6.); 
  %iso_from_rawdate(outvar=rficdtc, invar=cons_dat);
RUN;

/*RFPENDTC*/
DATA work.lastcont;
  LENGTH subjid lastcont $200;
  SET rawdata.conclus;
  subjid = PUT(pid,z6.); 
  %iso_from_rawdate(outvar=lastcont, invar=lc_rdat);
RUN;
PROC sort DATA=work.lastcont;
  BY subjid lastcont;
RUN;
DATA work.lastcont;
  SET work.lastcont;
  BY subjid lastcont;
  IF last.subjid;
RUN;

DATA work.lastact;
  LENGTH subjid lastact $200;
  SET rawdata.actdates;
  subjid = PUT(pid,z6.); 
  %iso_from_rawdate(outvar=lastact, invar=actrdate);
RUN;
PROC sort DATA=work.lastact;
  BY subjid lastact;
RUN;
DATA work.lastact;
  SET work.lastact;
  BY subjid lastact;
  IF last.subjid;
RUN;

DATA work.rfpendtc(KEEP = subjid rfpendtc);
  MERGE work.lastcont work.lastact;
  BY subjid;
  IF NOT(MISSING(lastcont)) THEN rfpendtc = lastcont;
  ELSE rfpendtc = lastact;
RUN;

/*DTH*/
DATA work.death;
  LENGTH subjid dthdtc dthfl $200;
  SET rawdata.ae(WHERE=(STRIP(outcome) = '5'));
  subjid = PUT(pid,z6.); 
  %iso_from_rawdate(outvar=dthdtc, invar=ae_erdat);
  dthfl = 'Y';
RUN;
PROC sort DATA=work.death;
  BY subjid dthdtc;
RUN;
DATA work.death;
  SET work.death;
  BY subjid dthdtc;
  IF LAST.subjid;
RUN;
     
/*Arm*/
%MACRO donotrun;

PROC sql NOPRINT;
  CREATE TABLE work.randcode1 AS 
  SELECT a.pid, b.grp_let AS armcd
  FROM rawdata.rnd_ctrl AS a LEFT JOIN rawdata.rando AS b
  ON a.rnd_itt = b.rnd_id;
QUIT;

PROC sql NOPRINT;
  CREATE TABLE work.randcode2 AS 
  SELECT a.pid, b.grp_let AS actarmcd
  FROM rawdata.rnd_ctrl AS a LEFT JOIN rawdata.rando AS b
  ON a.rnd_id = b.rnd_id;
QUIT;

PROC sort DATA=work.randcode1; BY pid; RUN;
PROC sort DATA=work.randcode2; BY pid; RUN;

DATA work.rando;
  MERGE work.randcode1 work.randcode2;
  BY pid;
RUN;

DATA work.rando (DROP = pid);
  LENGTH subjid $200;
  SET work.rando;
  
  subjid = PUT(pid,z6.); 
RUN;

%MEND donotrun;


PROC sql NOPRINT;
  CREATE TABLE work.rando AS     
  SELECT a.pid/*, a.subset*/, /*b.grp_let*/ b.group_nb
  FROM rawdata.rndalloc AS a LEFT JOIN rawdata.rando AS b
  ON a.rnd_id = b.rnd_id;
QUIT;

DATA work.rando;
 LENGTH subjid armcd actarmcd $200;
 SET rando;
 subjid = PUT(pid,z6.); 
 /*armcd = grp_let; 
 actarmcd = grp_let;*/
 
 armcd = STRIP(PUT(group_nb, BEST.)); 
 actarmcd = STRIP(PUT(group_nb, BEST.));
RUN;  


PROC sort DATA=work.dm1;      BY subjid; RUN;
PROC sort DATA=work.rfdates;  BY subjid; RUN;
PROC sort DATA=work.consent;  BY subjid; RUN;
PROC sort DATA=work.rfpendtc; BY subjid; RUN;
PROC sort DATA=work.death;    BY subjid; RUN;
PROC sort DATA=work.rando;    BY subjid; RUN;

DATA work.dm2;
  MERGE work.dm1(IN=a) work.rfdates work.consent work.rfpendtc work.death work.rando;
  BY subjid;
  IF a;
RUN;

/*country and so*/
DATA work.cntry;
  LENGTH siteid invid invnam country $200;
  SET rawdata.ctr_info;
  
  IF      SUBSTR(STRIP(center),1,2) = '00' THEN siteid = STRIP(SUBSTR(center,3));
  ELSE IF SUBSTR(STRIP(center),1,1) = '0'  THEN siteid = STRIP(SUBSTR(center,2));
  ELSE                                          siteid = STRIP(center);
  
  invid  = STRIP(UPCASE(inv_code));
  invnam = STRIP(invs_fir)||" "||STRIP(invs_las);
  
  IF cty_nam = '<...>' THEN country = '<...>';
  ELSE PUT "WAR" "NING: country " cty_cod=;
RUN;

PROC sort DATA=work.dm2;    BY siteid; RUN;
PROC sort DATA=work.cntry;  BY siteid; RUN;

DATA work.dm3;
  MERGE work.dm2(IN=a) work.cntry(DROP = center);
  BY siteid;
  IF a;
RUN;

PROC sort DATA=work.dm3;      BY subjid; RUN;

/*General setting*/
DATA work.sdtmdm(KEEP = studyid domain usubjid subjid rfstdtc rfendtc rfxstdtc rfxendtc rficdtc rfpendtc dthdtc dthfl siteid invid invnam brthdtc age ageu sex race ethnic armcd arm actarmcd actarm country)
     work.suppdm(KEEP = studyid domain usubjid raceoth raceor /*subset*/);
  LENGTH usubjid domain studyid rfstdtc rfendtc ageu actarm arm armcd actarmcd $200 age 8;
  SET work.dm3 (RENAME = (armcd=_armcd actarmcd=_actarmcd));
  
  domain  = STRIP(SYMGET("domain"));         
  studyid = STRIP(SYMGET("studyNr")); 
  
  usubjid = STRIP(studyid)||'-'||STRIP(subjid);
  IF dthdtc < rfpendtc AND NOT(MISSING(dthdtc)) THEN rfpendtc = dthdtc;
  
  armcd = PUT(_armcd, $200.); 
  actarmcd = PUT(_actarmcd, $200.); 
  
  IF MISSING(_armcd) THEN DO;
    armcd = 'NOTASSGN';
    arm   = 'Not Assigned';
  END;
  IF MISSING(_actarmcd) THEN DO;
    actarmcd = 'NOTASSGN';
    actarm   = 'Not Assigned';
  END;
  IF MISSING(rfxstdtc) AND NOT(actarmcd IN ('NOTASSGN','SCRNFAIL')) THEN DO;
    actarmcd = 'NOTTRT';
    actarm = 'Not Treated';
  END; 
  
  IF armcd IN ('SCRNFAIL', 'NOTASSGN') THEN rfendtc = ''; 
  ELSE rfendtc = rfpendtc;
  
  rfstdtc = rfxstdtc; 
  IF MISSING(rfxstdtc) THEN rfstdtc = rficdtc; 
  IF armcd IN ('SCRNFAIL', 'NOTASSGN') THEN rfstdtc = ' ';
 
  IF LENGTH(rficdtc) >= 10 AND LENGTH(brthdtc) >=10 THEN age = FLOOR((INPUT(SUBSTR(rficdtc,1,10), is8601da.) - INPUT(SUBSTR(brthdtc,1,10), is8601da.))/365.25);
  /*IF LENGTH(rficdtc) >= 10 AND LENGTH(brthdtc) >=10 THEN age = FLOOR((INPUT(SUBSTR(rficdtc,1,10), is8601da.) - INPUT(SUBSTR(brthdtc,1,10), is8601da.))/365.25*12);*/
  ELSE age = .;
  IF NOT(MISSING(age)) THEN ageu = 'YEARS';  
  /*IF NOT(MISSING(age)) THEN ageu = 'MONTHS';*/
  ELSE ageu = ' ' ; 
RUN;

PROC sort DATA=work.sdtmdm; BY usubjid; RUN;

/*Obtain the subjects in IE*/
PROC sort DATA=insdtm.ie(KEEP = usubjid) OUT=work.inie NODUPKEY; BY usubjid; RUN;
DATA work.sdtmdm;
  MERGE work.sdtmdm work.inie(in=b);
  BY usubjid;
  IF b then flag = 1;
RUN;

DATA work.sdtmdm(DROP = flag);
  SET work.sdtmdm;
  IF flag = 1 AND armcd = 'NOTASSGN' THEN DO;
    armcd = 'SCRNFAIL'; arm = 'Screen Failure';
  END; 
  IF flag = 1 AND actarmcd = 'NOTASSGN' THEN DO;
    actarmcd = 'SCRNFAIL'; actarm = 'Screen Failure';
  END;
RUN;

/*Get arm and actarm from TA*/
PROC sort DATA=insdtm.ta OUT=work.ta(KEEP = arm armcd RENAME=(arm = taarm)) NODUPKEY; BY armcd; RUN;
PROC sort DATA=work.sdtmdm; BY armcd; RUN;
DATA work.sdtmdm(DROP = taarm);
  LENGTH armcd $200;
  MERGE work.sdtmdm(IN=a) work.ta;
  BY armcd;
  IF a;
  IF MISSING(arm) THEN arm = taarm;
RUN;

PROC sort DATA=insdtm.ta OUT=work.ta(KEEP = arm armcd RENAME=(arm = taarm armcd=actarmcd)) NODUPKEY; BY armcd; RUN;
PROC sort DATA=work.sdtmdm; BY actarmcd; RUN;
DATA work.sdtmdm(DROP = taarm);
  LENGTH actarmcd $200;
  MERGE work.sdtmdm(IN=a) work.ta;
  BY actarmcd;
  IF a;
  IF MISSING(actarm) THEN actarm = taarm;
RUN;

DATA work.bdls; SET insdtm.dm; RUN;    

PROC sort DATA=work.bdls;   BY studyid usubjid ; RUN;
PROC sort DATA=work.sdtmdm; BY studyid usubjid ; RUN;   

proc compare data=work.sdtmdm compare=work.bdls criterion=0.0000001 LISTVAR; run;

proc contents data=work.sdtmdm out=work.basout NOPRINT; run;
proc contents data=work.bdls   out=work.bdlsout NOPRINT; run;
proc sql noprint;  SELECT distinct name into :basname separated by ' ' FROM work.basout; QUIT;
proc sql noprint;  SELECT distinct name into :bdlsname separated by ' ' FROM work.bdlsout; QUIT;

%put BAS : &basname;
%put BDLS: &bdlsname;

proc compare data=work.sdtmdm compare=insdtm.dm LISTVAR; run;    


DATA work.suppdm1(KEEP = studyid rdomain usubjid idvar idvarval qnam qval);
  LENGTH studyid rdomain usubjid idvar idvarval qnam qval $200;
  SET work.suppdm;
  
  rdomain = domain;
  qnam = 'RACEOR';
  qval = STRIP(raceor);
  idvar = ''; idvarval = '';
  IF NOT(MISSING(qval)) THEN OUTPUT;
  
  qnam = 'RACEOTH';
  qval = STRIP(raceoth);
  idvar = ''; idvarval = '';
  IF NOT(MISSING(qval)) THEN OUTPUT;
  
  /*qnam = 'SUBSET';
  qval = STRIP(subset);
  idvar = ''; idvarval = '';
  IF NOT(MISSING(qval)) THEN OUTPUT;*/ 
RUN; 
 
/* Compare SUPPDM datasets. */
PROC sort DATA=work.suppdm1  OUT=work.suppdm1;      BY studyid usubjid qnam; RUN;    
PROC sort DATA=insdtm.suppdm OUT=work.suppdm_bdls;  BY studyid usubjid qnam; RUN;

proc compare data=work.suppdm1 compare=work.suppdm_bdls; run;    

