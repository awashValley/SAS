/* [23-jun-2017]. SDTM - IS domain */
proc transpose data=cmi out=cmi_2_tr (rename=(_label_ = testdesc
                                              _name_  = lab_test)
                                      where=(col1 ne .));
   by studyid usubjid visitnum antigen;     
   var all_evt all_prt cd: dbl: ifng: il: tnfa: motality;
run;  
