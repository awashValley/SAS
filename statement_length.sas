
/* [Fri 01Apr2016]. Set lengths of only character variables at once 
  (source: http://stackoverflow.com/questions/35460055/setting-the-length-of-all-character-variables-within-a-dataser). */
  
  proc sql;
    select name into :names separated by ' '
    from dictionary.columns 
    where libname='WORK' and upcase(memname)='SAMPLE' and type='char';
  quit;

  data work.combined;
    length &names $200;
    set work.sample;
    stop;
  run;
