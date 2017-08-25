/* Define library. */
libname rwdat1 "<path1>" access=readonly;
libname rwdat2 "<path2>";

/* Copy source dataset. */
proc copy in=rwdat1 out=work memtype=data;
run;

/* Get list of source datasets where patientnumber/subjid exist. */
proc contents data=rwdat1._all_ out=_cnts_src_hybrid (keep = libname memname name);
run;

proc sort data=_cnts_src_hybrid nodupkey; by memname name; run; 

proc sql noprint;
  create table _cnts_src_hybrid2 as
  select *, 
         case when strip(lowcase(name)) EQ 'patientnumber' then '1'
              when strip(lowcase(name)) NE 'patientnumber' then '0' 
              else ''
         end as flg_pnumber, 
         case when strip(lowcase(name)) EQ 'subjid' then '1'
              when strip(lowcase(name)) NE 'subjid' then '0' 
              else ''
         end as flg_subjid
  from _cnts_src_hybrid
  order by memname;
quit;

data _cnts_src_hybrid3;
  set _cnts_src_hybrid2 (where =(flg_pnumber='1' or flg_subjid='1'));
run;

proc sql noprint;
  create table _cnts_src_hybrid4 as
  select *, count(*) as nbr_recds
  from _cnts_src_hybrid3
  group by memname;
quit;

data _cnts_src_hybrid5 (keep = memname);
  set _cnts_src_hybrid4 (where = (nbr_recds > 1));
run;

proc sort data=_cnts_src_hybrid5 nodupkey out=_cnts_src_hybrid6; by memname; run;


/* Update subjid variable using patientnumber. */
%let code = ;
data _cnts_src_hybrid7;
  length code_tmp code $ 25000;
  set _cnts_src_hybrid6 end=last;
  retain code;
  
  if _n_ = 1 then code='';
  code_tmp = "data work." || memname || ";" ||
               "set work." || memname || "(rename = (SUBJID = _SUBJID));" || 
               "SUBJID = input(strip(patientnumber), BEST.);" || 
             "run;";
  code = strip(code)||strip(code_tmp);
  
  if last then do;
     call symputx("code", code);
     put code;
  end;
run;

&code;

/* Export updated source dataset to new location. */
proc copy in=work out=rwdat2 memtype=data;
run;
