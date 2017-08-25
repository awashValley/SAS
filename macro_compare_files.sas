
%let old_study = study1;
%let new_study = study2;

%let old_mfs = <.../file1.XLSX;
%let new_mfs = <.../file2.XLSX;;

filename old "&_sasws_.&old_mfs.";
filename new "&_sasws_.&new_mfs.";

/* using infile_xls macro */
<read the XLS files into SAS>

proc sort data = work.old_mfs(where=(^missing(specification)) keep = dataset variable sdtm_ds sdtm_var specification);
  by dataset variable sdtm_ds sdtm_var specification;
run;
proc sort data = work.new_mfs(where=(^missing(specification)) keep = dataset variable sdtm_ds sdtm_var specification);
  by dataset variable sdtm_ds sdtm_var specification;
run;

data work.merge;
  length status $200;
  merge work.old_mfs (in=inold)
        work.new_mfs (in=innew);
  by dataset variable sdtm_ds sdtm_var specification;
  if inold and innew then status = 'MATCH';
  if inold and ^innew then status = 'DELETE';
  if ^inold and innew then status = 'ADD';
run;

proc sort data = work.merge;
  by sdtm_ds sdtm_var;
run;

%LET filename = COMPARE_&SYSDATE9.;
%let folder = <target>;

proc export data=work.merge outfile="...&folder./&filename..xlsx" 
            dbms = xlsx replace;
run;


