%macro read_formats(datafile=
                   ,sheet   =
				           ,outlib  =
                   );

  *----------------------------------------------------------------------------;
  * Read excel file that contains all formats.                                 ;
  *----------------------------------------------------------------------------;
  proc import datafile="&datafile"
              out     =allformats
              dbms    =xlsx replace;
              sheet   ="&sheet"; 
              getnames=YES;
  run;


  *----------------------------------------------------------------------------;
  * Create output data set ALLFORMATS in folder &outlib.                       ;
  *----------------------------------------------------------------------------;
  proc sort data=allformats
            out =&outlib..allformats;
    by name value;
  run;


  *----------------------------------------------------------------------------;
  * PROC FORMAT provides the option CNTLIN to which you can specify a data set ;
  * that will be transformed into a formats catalogue. This data step prepares ;
  * that data set (with minimally required variables FMTNAME, START, END and   ;
  * LABEL.                                                                     ;
  *----------------------------------------------------------------------------;
  data allformats(keep=fmtname start end label);
    length start $16
           end   $16;
    set allformats(rename=(name=fmtname));
    start=strip(put(value, 8.));
    end  =strip(put(value, 8.));
  run;

 
  *----------------------------------------------------------------------------;
  * Run PROC FORMAT and provide the previously prepared data set to generate   ;
  * the formats catalog from it.                                               ;
  *----------------------------------------------------------------------------;
  proc format cntlin=allformats;
  run;
%mend read_formats;
