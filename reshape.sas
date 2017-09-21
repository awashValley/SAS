
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
