
* [Wed 11May2016]. ;
  %macro test;
    /* %do i=3 %to 1;  */    * Wrong:   SAS will loop from 3, 4, 5, etc. ;      
    %do i=3 %to 1 %by -1;    * Correct: just use the keyword 'BY' without '=' sign. ;
      %put >> &i;
    %end;
  %mend;
  %test;
