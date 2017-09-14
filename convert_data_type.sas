/* [Thur, 14-Sep-2017]. Convert numeric variable to character. */
  IF    NOT MISSING(vsstresn) THEN vsstresc = PUT(vsstresn, BEST.);
  ELSE                             vsstresc = '';
