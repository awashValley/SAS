
* [Thur 28APR2016]. Generate exploratory graph per block. ;

%macro generateExplorGraph(analyby =);

  * Suppress ODS results. ;
  ods results off;

  * Get number of treatment groups. ;
/*  proc sql noprint;*/
/*    select count(distinct treatment) into :num_groups*/
/*    from work.analydata_tmp (where= (&analyBy));*/
/*  quit;*/

  * Get group means per block. ;
  proc means data=work.analydata_tmp (where= (&projectBy = "&analyBy"));
    class treatment &block;
    var response;       
    ods output Summary=out_summary;
  run;

  proc sort data=work.out_summary 
              out=work.out_summary;
    by treatment &block;
  run;

  * Get group means, all blocks combined. ;
  proc sql noprint;
    create table work.out_summary_combined as
    select treatment, 
           response_N, 
           round(mean(response_Mean), 0.01) as avg_combined,
           round(std(response_Mean),  0.01) as std_combined,
           min(response_Mean) as min_combined,
           max(response_Mean) as max_combined
    from work.out_summary
    group by treatment, response_N;
  quit;

  * Save group means per block. 
    - TEMPORARY: saved for testing purpose. ;
  ods rtf file="&tables.\avg_Exploratory-&parameter._&analyBy_label..rtf";
  proc print data=work.out_summary 
               (keep   =treatment &block response_N response_Mean 
                rename =(response_N    =N 
                         response_Mean =mean));

    title1 h=1 font=verdana "Summary table for &analyBy_label. data.";
    title2 h=1 font=verdana "parameter: &label_parameter";
    title3 h=1 font=verdana "transformation: &transf";
  run;
  ods rtf close;  

  * Save group means per block. 
    - Needed by frontEnd program to display summary statistics to users. ;
  ods rtf file="&tables.\avg_Exploratory_combined-&parameter._&analyBy_label..rtf";
  proc print data=work.out_summary_combined
               (rename= (response_N =N 
                         avg_combined      =mean 
                         std_combined      =std
                         min_combined      =min
                         max_combined      =max));

    title1 h=1 font=verdana "Summary table (all blocks combined) for &analyBy_label. data.";
    title2 h=1 font=verdana "parameter: &label_parameter";
    title3 h=1 font=verdana "transformation: &transf";
  run;
  ods rtf close;


  /*******************************************************************************
    Start plotting exploratory graphs.  
  *******************************************************************************/
  * Get maximum of group means. ;
  proc sql noprint;
    select max(response_Mean)+200 into :max_counts
    from work.out_summary;
  quit;

  * Define amount of change (breaks) on the y-axis. ;
  %if %sysevalf(&max_counts > 700) %then 
  %do;
    %let by_breaks =200;
  %end;
  %else 
  %do;
    %let by_breaks =50;
  %end;

  * Reset graphical devices. ;
  goptions reset=all;

  * Define plot title. ;                                                                                                    
  title1 h=1.3 font=verdana "&label_parameter.: &analyBy_label";    

  * Define plot symbol. ;
  proc import datafile="&datapath.\Supportive\symbolTable.xlsx"
            out      =work.symbolTable
            dbms     =xlsx replace;
            sheet    ="sheet1";
            getnames =YES;
  run;

  proc sql noprint;
    create table work.symbol as
    select A.treatment,
           B.color,
           B.shape,
           B.line
    from work.out_summary_combined as A,
         work.symbolTable as B
         where A.treatment = B.treatment;
  quit;

  %symbol(data=symbol, group=treatment, para=%str());  
                                                                                                                                
  * Define plot legend. ; 
  proc sql noprint;
    select cats(strip(' " '), catx(" ", 'Group', treatment), strip(' " ')) into :legend_all separated by ' ' 
    from work.Out_summary_combined
    ;

    select count(treatment) into :num_groups
    from work.Out_summary_combined
    ;
  quit; 

  legend1 label    =none
          value    =(h=1.10 font=verdana &legend_all)   
          across   =1 down=&num_groups    
          position =(top right inside)
          mode     =share
          cborder  =black;                                                                                                               
                                                                                                                                        
  * Define plot axises. ;                                                                      
  axis1 label =(font=verdana "Interval (5 min.)")
        minor =none;    
  axis2 label =(angle=90 font=verdana "Counts")
        order =(0 to &max_counts by &by_breaks)
        minor =none;         

  * Plot summary graph per interval. ;
  ods rtf file="&plots.\plots_Exploratory-&parameter._&analyBy_label..rtf";
  proc gplot data=work.out_summary;
    plot response_Mean*&block = treatment  / haxis=axis1 vaxis=axis2 legend=legend1;
  run;
  quit;
  ods rtf close;

  * Delete temporary datasets. ;
  proc datasets nolist library=work;
    delete  
      out_summary out_summary_combined
      out 
      symboltable symbol
    ;
  run;
  quit;

%mend generateExplorGraph;
