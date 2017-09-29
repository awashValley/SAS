/* [23-jun-2017]. SDTM - IS domain */
proc transpose data=cmi out=cmi_2_tr (rename=(_label_ = testdesc
                                              _name_  = lab_test)
                                      where=(col1 ne .));
   by studyid usubjid visitnum antigen;     
   var all_evt all_prt cd: dbl: ifng: il: tnfa: motality;
run;  


/* [Fri, 29-Sep-2017]. Transpose supplemental qualifier domain dataset (i.e., from long to wide). */
PROC TRANSPOSE DATA=suppis OUT=suppis_tr (DROP = _name_ _label_);
  BY usubjid isseq;
  ID qnam;
  VAR qval;
RUN;
