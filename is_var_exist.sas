
/* [Thu, 27OCT2016]. Check if variable exists in SAS dataset.  */
%MACRO is_var_exist(var     =,
                    dset_in =,
                    lib_in  =);

   DATA _NULL_;
     dset = OPEN("&lib_in..&dset_in.");
     
     CALL SYMPUT("is_exist", varnum(dset, "&var."));
   RUN;

   %PUT >>> ------------------------------------ ;
   %PUT >>> is_exist (&var.): &is_exist          ;
   %PUT >>> ------------------------------------ ;

%MEND  is_var_exist;
