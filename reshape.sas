
/* [Thur, 21-Sep-2017].  collapse multiple rows into one. */
DATA work.metadata_header3 (DROP = _header_xls header_txt);
  LENGTH header_xls $ 2000;
  SET work.metadata_header2;
  RETAIN header_xls;
  
  BY category_num;
  
  IF           FIRST.category_num THEN header_xls = '';
  ELSE IF NOT  FIRST.category_num THEN header_xls = STRIP(header_xls) || STRIP(_header_xls);
  
  IF LAST.category_num THEN OUTPUT;
RUN;
