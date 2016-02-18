/* [18FEB2016] PROC COPY vs DATA statement to copy a file? 
   - The former is more efficient becuase
     1. it keeps the labels of source data which would be dropped if a DATA statement is used; 
     2. it's faster and more efficient since it doesn't copy data per record which is the way SAS DATA statement works.
*/
