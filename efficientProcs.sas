/* [18FEB2016] PROC COPY vs DATA statement to copy a file? 
   - The former is more efficient becuase
     1. it keeps the labels of source data which will be dropped by the later procedure; 
     2. it's faster and more efficient since it doesn't copy per record like DATA statement.
*/
