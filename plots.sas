* [Thur 17Mar2016]. Plot confidence intervals of estimates over time. ;
  proc sgplot data=work.out_diffs_time_1vs2 noautolegend;
    title "Adjusted group mean differences over time: group1 vs group 2";
    scatter y=Estimate x=time /
      yerrorlower=AdjLower 
      yerrorupper=AdjUpper;
    xaxis label="Time";
    yaxis grid discreteorder=data label="Mean Differences"; 
  run;
  


/* [Tue 22Mar2016]. Plot graphs using GPLOT */
   goptions reset=all;

   * Define the title. ;                                                                                                    
   title1 h=1.3 font=verdana "Hello, world!";                                                                                      
                                                                                                                                        
   * Define symbol characteristics. ;                                                                                                  
   symbol1 i=join v=diamondfilled  c=green  h=1;                                                                       
   symbol2 i=join v=squarefilled   c=orange h=1;                                                                         
   symbol3 i=join v=trianglefilled c=blue   h=1; 
   symbol4 i=join v=star           c=red    h=1;  
                                                                                                                                        
   * Define legend characteristics. ;                                                                                                    
   legend1 label    =none
           value    =(h=1.10 font=verdana "Group 1" "Group 2" "Group 3" "Group 4")   
           across   =1 down=&num_groups    
           position =(top right inside)
           mode     =share
           cborder  =black;                                                                                                               
                                                                                                                                        
   * Define axis characteristics. ;                                                                      
   axis1 label =(font=verdana "Interval (5 min.)")
         minor =none;   /* to remove tick marks on the axis */   
   axis2 label =(angle=90 font=verdana "Counts")
         order =(0 to &max_counts by &by_breaks)
         minor =none;         

   * Plot animal movements per group. ;
   proc gplot data=work.out_summary;
     plot response*interval = treatment  / haxis=axis1 vaxis=axis2 legend=legend1;
   run;

  
* [Tue 22Mar2016]. Save residual plots on external device. ;
  ods results off;

  ods graphics on /reset=index imagename="residual_plots" 
                   border=off;

  ods listing style =journal 
              gpath ="&plots";
  proc mixed data=work.analydata_tmp method=REML;
    class treatment interval id;
    model response = treatment interval treatment*interval /ddfm=KenwardRoger residual;  * diagnostics from the "residual" option. ;
    repeated interval /subject=id type=&final_cov;
  run;
  ods listing close;
  ods graphics off;  
