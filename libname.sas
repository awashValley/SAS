
* [25FEB2016]. ;
*------------------------------------------------------------------------;
* Mimic library mylib as the macro %testMacro expects it to exist. In    ;
* this program, it refers to WORK. Then, include the macro program code. ;
*------------------------------------------------------------------------;
libname mylib "%sysfunc(pathname(work))";
%include "&path.\testMacro.sas";


/* [26FEB2016] Define the PC Files engine library. 
   Why we need the option "pcfiles" */
  libname mylib pcfiles path="&path.\&fileTest.";
