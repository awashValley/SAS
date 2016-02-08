
/* NOTE (Log file): Character to numeric conversions...
                    Debug: Use an INPUT statement since MDY is a numeric function. */
	 if   length(varChar)=10 then varNum=mdy(input(substr(varChar, 6, 2), 8.), 
	                                         input(substr(varChar, 9, 2), 8.), 
	                                         input(substr(varChar, 1, 4), 8.));
	 else                         varNum=.;
