
/* [Thur, 16-Mar-2017]. Difference between MERGE & SET */
/* - If you would use SET statement, value of inelig variable would be always missing. */
DATA work.demog;
  LENGTH inelig 8;
  MERGE work.demog (IN=a) work.eligibil (IN=b);

  BY subjid;
  IF a;
  IF b THEN inelig=1;    
RUN;
