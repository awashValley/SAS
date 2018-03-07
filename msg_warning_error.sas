
/* [07-Mar-2018]. Query to triger. */
data lb;
	merge adsl(in = inadsl) lb(in = inlb);
	by usubjid;
	if inlb and not inadsl then
		put "WARN" "ING: Missing treatment assignment for subject " usubjid=;
	if inadsl and inlb;
run;
