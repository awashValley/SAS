
/* [Thur, 22SEP2016]. Suppress max length */
/* WARNING: The quoted string currently being processed has become more than 262 bytes long.  You might have unbalanced quotation marks. */
/* Fix by using the ff OPTION */
   OPTIONS NOQUOTELENMAX; 
   
/* Suppress multiple lengths */
   OPTIONS VARLENCHK = NOWARN

/* [08-May-2018]. To upcase column names in SAS */
options validvarname=upcase;      * To upcaase column names. ;
