
/* ---------------------------------------------------------------------------------- */
/* Description: This macro is created to view the nature of the rawdata or study data */
/*              used in data checks program.                                          */
/* Programmer:  awashValley                                                           */
/* Date:        November 01, 2016                                                     */
/* ---------------------------------------------------------------------------------- */

%MACRO chk15_view_srcData(dsin       =,
                          keep_vars  =,
                          is_refname =,
                          filter_by  =,
                          dsout      =,
                          debugme    =);
  
  
  %IF       %UPCASE(&debugme) = Y %THEN %DO;
    OPTIONS MPRINT MLOGIC SYMBOLGEN;
  %END;
  %ELSE %IF %UPCASE(&debugme) = N %THEN %DO;
    OPTIONS NOMPRINT NOMLOGIC NOSYMBOLGEN;
  %END;
  
  %LOCAL refname_variables;
  %LET refname_variables = sitemnemonic visitnum chapterrefname visitindex formrefname formindex sectionrefname;
  
  /* View the source dataset */
  DATA &dsout;
    SET &dsin (KEEP = &keep_vars 
      %IF %UPCASE(&is_refname.) = Y %THEN %DO;
        &refname_variables.
      %END;
    );
    
    WHERE &filter_by.;
    
  RUN;
   
%MEND  chk15_view_srcData;
