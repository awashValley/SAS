%let rootfolder=C:\_tmp;

* use doble quote to scape. ;
* '/s' to get access to subfolders. ;
* '/b' to get files only. ;
filename alllogs pipe "dir /s /b ""&rootfolder.\*.log""";

data work.alllogs;
  infile alllogs dsd dlm="00"x;
  length filename $ 1000;
  input filename $;
run;

* close filename. ;
filename alllogs;

%macro getLogResults(filename=);

  * run 'findstr' function, which is regex application in batch mode. ;
  filename logres pipe "findstr /i /n /g:""&rootfolder.\Supportive\search.txt"" ""&filename"" | findstr /i /v /g:""&rootfolder.\Supportive\search_not.txt""";

  data work.logres;
    infile logres dsd dlm="00"x;
    length filename line $ 1000;
    input line $;
    
    * trancate lengthy name. ;
/*	filename = tranwrd("&filename", "&rootfolder", "");*/
  run;

  filename logres;

  data work.allresults;
    set work.allresults
	    work.logres;
  run;

%mend getLogResults;

data work.allresults;
  length filename line $ 1000;
  call missing(of _all_);
  if 0;
run;


data work.code;
  set work.alllogs;
  length code $ 1000;
  code = cats('%getLogResults(filename=', filename, ');');
  call execute(code);
run;
