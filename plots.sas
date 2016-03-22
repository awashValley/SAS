* [Thur 17Mar2016]. Plot confidence intervals of estimates over time. ;
  proc sgplot data=work.out_diffs_time_1vs2 noautolegend;
    title "Adjusted group mean differences over time: group1 vs group 2";
    scatter y=Estimate x=time /
      yerrorlower=AdjLower 
      yerrorupper=AdjUpper;
    xaxis label="Time";
    yaxis grid discreteorder=data label="Mean Differences"; 
  run;
  
  
* [Tue 22Mar2016]. Send plots to external location. ;
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
