
/* [Thur, 21-Sep-2017].  collapse multiple rows into one. */
DATA work.metadata_header3 (DROP = _header_xls header_txt);
  LENGTH header_xls format_var $ 2000;
  SET work.metadata_header2;
  RETAIN header_xls format_var;
  
  BY category_num;
  
  IF FIRST.category_num THEN DO;
    header_xls = _header_xls;
    format_var =  header_txt;
  END;
  ELSE IF NOT FIRST.category_num THEN DO;
    header_xls = CATX(' ', header_xls, _header_xls);
    format_var = CATX(' ', format_var,  header_txt);
  END;
  
  IF LAST.category_num THEN OUTPUT;
RUN;

/* [Mon, 04-jun-2018]. Reshape - efficient (i.e., use "_N_=1" condition, instead of "first.count") */
proc sort data=work.stat_char01 out=work.stat_char02;
  by count;
run;

data work.details_long;
  length stat_long details_long $ 200;
  set work.stat_char02 end=last;
  retain details_long stat_long;

  by count;

  * Combine values. ;
  stat_long = catx("  ", &sel_var., 
                         cats("(", count, "x)"));

  * Create long details. ;
  if   _N_=1 then details_long = stat_long;
  else            details_long = catx(" ", details_long, stat_long);
 
  if last then output;
run;
