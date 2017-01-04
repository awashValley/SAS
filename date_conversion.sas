
* convert SAS date (e.g., 15NOV2011) to charcter date (2011-11-15). ;
  if   dmbthdtn^=. then dmbthdt=          substr(put(dmbthdtn, mmddyy10.), 7, 4)
                                || "-" || substr(put(dmbthdtn, mmddyy10.), 1, 2)
                                || "-" || substr(put(dmbthdtn, mmddyy10.), 4, 2);
  else            	dmbthdt=.;

* Define day of birth. ;
  if   dmbthdtn^=. then dmbthday=input(substr(put(dmbthdtn, mmddyy10.), 4, 2), 8.0);
  else                  dmbthday=.;

* Define month of birth. ;
  if   dmbthdtn^=. then dmbthmth=input(substr(put(dmbthdtn, mmddyy10.), 1, 2), 8.0);
  else                  dmbthmth=.;
	
* Define year of birth. ;
  if   dmbthdtn^=. then dmbthyr=input(substr(put(dmbthdtn, mmddyy10.), 7, 4), 8.0);
  else                  dmbthyr=.;

* charater date to SAS date. ;
if     varyr ^=.
   and varmth^=.
   and varday^=. then do;  vardt =                     put(varyr, 4.)
                                   || "-" || translate(put(varmth, 2.), "0", " ")
			           || "-" || translate(put(varday, 2.), "0", " ");
	                   vardtn=mdy(varmth, varday, varyr);
                      end;
end;

* charater date to SAS date (version 2). ;
  if   length(vardt)=10 then vardtn=mdy(substr(vardt, 6, 2), substr(vardt, 9, 2), substr(vardt, 1, 4));
  else                       vardtn=.;

/* ------------------------------------------------------  */
/* Giving a window to investigator where the next visit be */
/* - calculate date difference                             */
/* ------------------------------------------------------  */
PROC SQL NOPRINT;
  CREATE TABLE one AS
  SELECT INTNX('MONTH',INTNX('YEAR',INPUT(A.visdat, DATE9.), E.min_int), MONTH(INPUT(A.visdat, DATE9.))-1)+DAY(INPUT(A.visdat, DATE9.))-1 AS min_date FORMAT DATE9. 
       , INTNX('MONTH',INTNX('YEAR',INPUT(A.visdat, DATE9.), E.max_int), MONTH(INPUT(A.visdat, DATE9.))-1)+DAY(INPUT(A.visdat, DATE9.))-1 AS max_date FORMAT DATE9.
       
  FROM WORK.test
  ;

QUIT;
