/* [Wed, 19OCT2016]. %NRSTR function. */
%MACRO prog1(chk_prog =,
             chk_lib  =,
             chk_dset =,
             chk_vars =,             
             lib_out  =);

    /* Filter dataset and keep only variables mentioned in Data Check. */
  %IF &chk_vars ^= %STR( ) %THEN %DO;
     
    LIBNAME chk_lib "&chk_lib";
    
    PROC SQL NOPRINT;
      CREATE TABLE lbout.qwe AS
      SELECT &chk_vars
      FROM chk_lib.&chk_dset
      ;
    QUIT;
  
  %END;
  
%MEND  prog1;

%LET lst_ds    = %nrstr(subjid, visitnum, dsdiscnt);   // "nrstr" tells SAS the commas are not separator for parameters, but part of the list
%LET lib_harro = &inpdt;
 
%prog1(chk_prog =&chk_prog, chk_lib=&lib_harro, chk_dset=ds, chk_vars=&lst_ds, lib_out=&lb_hw1);
