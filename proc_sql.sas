
## How to get row numbers in SAS proc sql;
  PROC sql;
    SELECT *, monotonic() as obs_count
      FROM &dlbIn
    WHERE calculated obs_count=100;
  QUIT;
  
  ## OR - SAS data statement can also be used.
  DATA dset;
    SET &dlbn;
    IF _n_ = &seed;
  RUN;
