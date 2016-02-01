
* convert SAS date (e.g., 15NOV2011) to charcter date (2011-11-15). ;
  if   iidtn^=. then iidt=          substr(put(iidtn, mmddyy10.), 7, 4)
                          || "-" || substr(put(iidtn, mmddyy10.), 1, 2)
                          || "-" || substr(put(iidtn, mmddyy10.), 4, 2);
  else               iidt=.;

	* Define day of birth. ;
  if   dmbthdtn^=. then dmbthday=input(substr(put(dmbthdtn, mmddyy10.), 4, 2), 8.0);
	else                  dmbthday=.;

	* Define month of birth. ;
  if   dmbthdtn^=. then dmbthmth=input(substr(put(dmbthdtn, mmddyy10.), 1, 2), 8.0);
	else                  dmbthmth=.;
	
	* Define year of birth. ;
  if   dmbthdtn^=. then dmbthyr=input(substr(put(dmbthdtn, mmddyy10.), 7, 4), 8.0);
	else                  dmbthyr=.;
