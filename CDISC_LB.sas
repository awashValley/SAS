/* [Mon, 25-Sep-2017]. Calculate LB baseline flag (LBBLFL) variable. */
PROC SORT DATA=work.lb6 OUT=work.lb7;
  BY usubjid lbcat lbmethod lbspec lbtestcd DESCENDING lbdtc;
RUN;

DATA work.lb8;
  LENGTH lbblfl $ 200;
  SET work.lb7;
  RETAIN lbblfl;
  
  BY usubjid lbcat lbmethod lbspec lbtestcd DESCENDING lbdtc;
  
  IF FIRST.lbtestcd THEN lbblfl = '';
  IF (SUBSTR(lbdtc, 1, 10) <= SUBSTR(rfxstdtc, 1, 10)) AND NOT MISSING(lborres) AND lbblfl = '' THEN  lbblfl = 'Y';
RUN;
