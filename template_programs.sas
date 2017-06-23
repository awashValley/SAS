/* [23-jun-2017]. Credit MH, zLabSpecialist. */
*unique mapped: mapped test in the mapping master 1 to 1;
proc sql;
   *coun double source_code;
   create table _unique_mapped_0 as
      select source_code
            ,istestcd
            ,count(*) as count_source_code
      from _metadata_new
      group by source_code
      having count(*)>1;
      
   *count double istestce;
   create table _unique_mapped_1 as
      select source_code
            ,istestcd
            ,count(*) as count_testcd
      from _metadata_new
      group by istestcd
      having count(*)>1;
   
   *combine counts with metadata;
  create table __mapped_1_to_1 as
     select a.*
           ,b.count_source_code
           ,c.count_testcd
     from _metadata_new as a 
        left join _unique_mapped_0 as b on a.source_code=b.source_code and a.istestcd=b.istestcd
        left join _unique_mapped_1 as c on a.source_code=c.source_code and a.istestcd=c.istestcd
     ;
quit;  
