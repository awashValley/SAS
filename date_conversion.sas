
* convert SAS date (e.g., 15NOV2011) to charcter date (2011-11-15). ;
    if   iidtn^=. then iidt=          substr(put(iidtn, mmddyy10.), 7, 4)
                            || "-" || substr(put(iidtn, mmddyy10.), 1, 2)
                            || "-" || substr(put(iidtn, mmddyy10.), 4, 2);
	  else               iidt=.;
