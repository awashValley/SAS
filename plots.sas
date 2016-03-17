* [Thur 17Mar2016]. Plot confidence intervals of estimates over time. ;
  proc sgplot data=work.out_diffs_time_1vs2 noautolegend;
    title "Adjusted group mean differences over time: group1 vs group 2";
    scatter y=Estimate x=time /
      yerrorlower=AdjLower 
      yerrorupper=AdjUpper;
    xaxis label="Time";
    yaxis grid discreteorder=data label="Mean Differences"; 
  run;
