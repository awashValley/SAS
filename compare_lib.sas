/* [Tue, 11OCT2016]. Under construction... */
/* Compare results obtained from val1_MAKEFINALDOMAIN.SAS and val12_MAKEFINALDOMAIN.SAS. */
%MACRO compare_lib(base_path =,
                   comp_path =,
                   num_ds    =);

  /* Define libnames. */
  LIBNAME lib1 "&base_path";
  LIBNAME lib2 "&comp_path";
  
  /* Determine number of datasets to compare. */
  PROC SQL NOPRINT;
    SELECT memname, count(memname) into :ds_lib1 SEPARATED BY " ",
                                        :cnt_lib1 
    FROM dictionary.tables
    WHERE libname=upcase("lib1")
    ORDER BY memname;
        
    SELECT memname, count(memname) into :ds_lib2 SEPARATED BY " ",
                                        :cnt_lib2 
    FROM dictionary.tables
    WHERE libname=upcase("lib2")
    ORDER BY memname;
  QUIT;

  /* Compare all expected datasets. */
  %IF &cnt_lib1 ^= cnt_lib2 %THEN %DO;
    %PUT ### --------------------------------------------------------------------------------------------------------------- ###;
    %PUT ### ERROR: the number of dataset in the libraries are different since cnt_lib1: &cnt_lib1. and cnt_lib2: &cnt_lib1. ###;
    %PUT ### --------------------------------------------------------------------------------------------------------------- ###;
  %END;
  %ELSE %DO;
    
    %DO i=1 %TO &cnt_lib1;
      
    %END;
  %END;

%MEND  compare_lib;
  
%LET root_path = &_sasws_./GSKVX/Files/SAS_DEV/MACRO/STANDARD/SDTM/MAKEFINALDOMAIN/VER 01_00;
%LET usr = /HW1;

%LET base_path = &root_path./VALIDATION/Test Data/Input1;
%LET comp_path = &root_path./VALIDATION/Test Data/Input1&usr;

%PUT >>> ds_lib2: &ds_lib2;
%PUT >>> cnt_lib2: &cnt_lib2;
