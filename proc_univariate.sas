
/* [Fri 27May2016]. Suppress summary tabe from histogram. 
                    - Include "noprint" option in the HISTOGRAM statement. */
   proc univariate data=sashelp.class noprint;
      var age;
      histogram /normal (noprint color=red w=1.75) ncols=2;
   run;
