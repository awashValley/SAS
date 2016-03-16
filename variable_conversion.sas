* Convert numeric variable to character. ;
  varChar1=put(varNum1, 6.0);   
	
* Convert character to character with different lengths (e.g., varChar2_org had 100 length). ;
  varChar2_new=put(varChar2_org, $50.);
  
* [WED 16Mar2016]. Redefine variable as character variable. ;
  data work.test (drop=_interval);
    length interval $2;
    set work.test(rename= (interval =_interval));

    interval =put(_interval, 2.);
  run;
