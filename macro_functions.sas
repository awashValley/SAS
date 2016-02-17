* How to include list of strings as value for an argument. ;
  %update_values(inset  =domx&&studynum&i
                ,outset =domx&&studynum&i
	  	,sortvar=%str(studyid, siteid, subjid, visitn, var1, var2, var3)
		,domain =domx);
