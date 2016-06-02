
* [Thur 02JUN2016]. Search patterns using LIKE operator. ;
  proc sql noprint;
    select distinct memname into :grps_test separated by ' '
    from dictionary.columns
    where     upcase(libname) ='WORK'
          and upcase(memname) like '%PERFPARMTEST%'
          and upcase(memname) like '%_M'
    ;
  quit;
  
  * The above code would return "PERFPARMTEST_AMBULATIONS_M PERFPARMTEST_TOTAL_MOVEMENTS_M" form the list
    "PERFPARMTEST_AMBULATIONS_M PERFPARMTEST_TOTAL_MOVEMENTS_M PERFPARMTEST_AMBULATIONS_F PERFPARMTEST_TOTAL_MOVEMENTS_F" .;
    
    
* [Thur 02JUN2016]. Using concatenation within LIKE operature.;
  proc sql;
      create table test3 as
      select * from test1
      left join test2
            on a like '%'||strip(search)||'%'
      ;
  quit;
  
  proc sql noprint;
    select distinct memname into :cnt_test2 separated by ' '
    from dictionary.columns
    where     upcase(libname) ='WORK'
          and upcase(memname) like 'PERFPARMTEST%'
          and upcase(memname) like '%'||'_'||strip(upcase("&analyBy"))
    ;
  quit;

  
