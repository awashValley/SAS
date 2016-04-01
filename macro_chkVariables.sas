
/*****************************************************************************************
Name       : chk_variables
Description: Check number of variables
Input      : input.<all variables>            
Output     : checkdata.variables.rtf
*****************************************************************************************/

proc format;
  value typef 1="Num"
              2="Char";
run;

%let mpath   =%str(C:\tmp);
%let usrData   =%str(C:\tmp\mrx);

libname I201_001 "&mpath.\old_database";

libname S2013121 "&mpath.\new_study";

%macro variablecheck(lib=);
	proc contents data   =&lib.._all_
	              memtype=data
				  out    =out_&lib noprint;
	run;

	proc sort data=out_&lib(keep=libname memname name type length label format formatl);
	  by memname name type length label format formatl;
	run;

	data out_&lib(drop=formatl libname);
	  set out_&lib;
	  by memname name type length label format formatl;
	  if   first.memname then &lib=1;
	  else                    &lib+1;

	  if formatl>0 then format=compress(format) || compress(formatl);

	  if      upcase(memname)="AEDD" or upcase(memname)="AE10S31" then memname="AE";
	  else if upcase(memname)="CODD" or upcase(memname)="CO10S31" then memname="CO";
	  else if upcase(memname)="DMDD" or upcase(memname)="DM10S31" then memname="DM";
	  else if upcase(memname)="DSDD" or upcase(memname)="DS10S31" then memname="DS";
	  else if upcase(memname)="DVDD" or upcase(memname)="DV10S31" then memname="DV";
	  else if upcase(memname)="EXDD" or upcase(memname)="EX10S31" then memname="EX";
	  else if upcase(memname)="FCDD" or upcase(memname)="FC10S31" then memname="HI";
	  else if upcase(memname)="HIDD" or upcase(memname)="HI10S31" then memname="HI";
	  else if upcase(memname)="ICDD" or upcase(memname)="IC10S31" then memname="IC";
	  else if upcase(memname)="IEDD" or upcase(memname)="IE10S31" then memname="IE";
	  else if upcase(memname)="IIDD" or upcase(memname)="II10S31" then memname="II";
	  else if upcase(memname)="IVDD" or upcase(memname)="IV10S31" then memname="IV";
	  else if upcase(memname)="KVDD" or upcase(memname)="KV10S31" then memname="KV";
	  else if upcase(memname)="MHDD" or upcase(memname)="MH10S31" then memname="MH";
	  else if upcase(memname)="PDDD" or upcase(memname)="PD10S31" then memname="PD";
	  else if upcase(memname)="PEDD" or upcase(memname)="PE10S31" then memname="PE";
	  else if upcase(memname)="PTDD" or upcase(memname)="PT10S31" then memname="PT";
	  else if upcase(memname)="RADD" or upcase(memname)="RA10S31" then memname="RA";
	  else if upcase(memname)="SCDD" or upcase(memname)="SC10S31" then memname="SC";
	  else if upcase(memname)="SEDD" or upcase(memname)="SE10S31" then memname="SE";
	  else if upcase(memname)="SHDD" or upcase(memname)="SH10S31" then memname="SH";
	  else if upcase(memname)="SVDD" or upcase(memname)="SV10S31" then memname="SV";
	  else if upcase(memname)="TADD" or upcase(memname)="TA10S31" then memname="TA";
	  else if upcase(memname)="TEDD" or upcase(memname)="TE10S31" then memname="TE";
	  else if upcase(memname)="TIDD" or upcase(memname)="TI10S31" then memname="TI";
	  else if upcase(memname)="TSDD" or upcase(memname)="TS10S31" then memname="TS";
	  else if upcase(memname)="TVDD" or upcase(memname)="TV10S31" then memname="TV";
	  else if upcase(memname)="VSDD" or upcase(memname)="VS10S31" then memname="TV";

	  else if upcase(memname)="DEMOG"   then memname="DM";
	  else if upcase(memname)="MEDHIS2" then memname="MH";

	  name=upcase(name);
	  format type typef.;
	run;

	proc sort data=out_&lib;
	  by memname name type length label format;
	run;
%mend variablecheck;


%variablecheck(lib=old_database);
%variablecheck(lib=new_study);




data alldata;
  merge out_old_database
        out_new_study
        
  ;
  by memname name type length label format;

  if memname = "RA" then output;
run; 

options orientation=landscape;

proc freq data=alldata;
  tables memname/nopercent;
run;

ods rtf body="&usrData.\Checkdata\&block.\&dom._chekVariables.rtf";
proc print data=alldata;
run;
ods rtf close;
