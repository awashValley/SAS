
/* [08FEB2016]. Log File (NOTE): Character to numeric conversions...
                Debug: Use an INPUT statement since MDY is a numeric function. */
   if   length(varChar)=10 then varNum=mdy(input(substr(varChar, 6, 2), 8.), 
	                                   input(substr(varChar, 9, 2), 8.), 
	                                   input(substr(varChar, 1, 4), 8.));
   else                         varNum=.;
   
   
/* [12FEB2016] Becareful using NODUPKEY option in PROC sort. */
