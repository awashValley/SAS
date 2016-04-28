
/* [Thur 28APR2016]. Movements of subjects over time per group. */

%macro plotMeanDifferences;
  /*******************************************************************************
    Plot adjusted mean diffrences with 95% confidence intervals.
  *******************************************************************************/

  * Get number of treatment groups, except the control group. ;  
  proc sql noprint;
    select count(distinct _treatment) into :numOfTrts
    from work.out_diffs2
    ;
  quit;

  * Plot C.I.s of group mean differences for all intervals combined. ;
  data work.out_diffs_combined;
    length xaxis $20;
    set work.out_diffs2;
    where missing(&block) & missing(&_block);

    %do l=2 %to (&numOfTrts + 1);
      if _treatment=&l then xaxis="Group &control. vs &l";
    %end;
  run;

  ods rtf file="&plots.\plots_CIs_combined-&transf._&parameter._&analyBy_label..rtf";
  ods graphics / reset=all border=off width=600px height=400px;
  proc sgplot data=work.out_diffs_combined noautolegend;
    title h=0.8 font=verdana "Adjusted group mean differences of &label_parameter.: all blocks combined";
    footnote1 h=1 justify=L font=verdana "Sex: &analyBy_label";
    footnote2 h=1 justify=L font=verdana "Transformation: &transf";

    scatter y=Estimate x=xaxis /yerrorlower=AdjLower yerrorupper=AdjUpper;
    xaxis label='Treatment groups';
    yaxis grid discreteorder=data label="Mean Differences"; 
  run;
  ods rtf close;

  * Plot C.I.s of group mean differences per block. ;
  ods rtf file="&plots.\plots_CIs_perInterval-&transf._&parameter._&analyBy_label..rtf";
  ods graphics / reset=all border=off width=600px height=400px;

  %do m=2 %to (&numOfTrts + 1);

    data work.out_diffs_block; 
      set work.out_diffs2;
      where     ^missing(&block) 
            and ^missing(&_block)
            and _treatment = &m
      ;
    run;

    proc sgplot data=work.out_diffs_block noautolegend;
      title h=0.8 font=verdana "Adjusted group mean differences of &label_parameter. per block: group &control. vs group &m";
      footnote1 h=1 justify=L font=verdana "Sex: &analyBy_label";
      footnote2 h=1 justify=L font=verdana "Transformation: &transf";

      scatter y=Estimate x=&block /yerrorlower=AdjLower yerrorupper=AdjUpper;
      xaxis label="Interval";
      yaxis grid discreteorder=data label="Mean Differences"; 
    run;

  %end;

  ods rtf close;

  * Delete temporary datasets. ;
  proc datasets nolist library=work;
    delete 
      out_diffs out_diffs2 
      out_diffs_combined out_diffs_block;
  run;
  quit;

%mend  plotMeanDifferences;
