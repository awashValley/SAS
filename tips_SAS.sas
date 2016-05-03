* [Wed 06Apr2016]. Show keys using F9. ;

* [Tue 03May2016]. Don't flag TEMPORARY codes.;
  data work.test;
    set work.orig;
  
    rownum = _n_;   /* TEMPORARY: consult the .NET developer */ 
  run;
  
  * Rather, specify as shown below. ;
  data work.test;
    set work.orig;
    
    if _n_ = 1 then put "ER" "ROR: Temporary solution; may require updates later.";
    rownum = _n_;   
  run;
   
