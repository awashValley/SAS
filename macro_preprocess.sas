
* [Thur 08Apr2016]. Preprocessing, i.e., exclusion and transformation.;

%macro preprocess;
/*******************************************************************************
  Preprocess the imported dataset.
*******************************************************************************/

  * Get imported dataset (only parameter of interest is kept).;
  data work.preprocess_tmp;
    set work.combined_ds (keep   =&keep_vars_wtpars &parameter
                          rename =(&parameter=response) );
  run;

  * Create a label. ;
  %if       %upcase(&parameter) = XYZ %then
  %do;
    %let label =%str(&label_xyz);
  %end;
  %else %if %upcase(&parameter) = ABC %then
  %do;
    %let label =%str(&label_abc);
  %end;


  * Apply exclusion. ;
  %applyExclusion;

  * Apply transformation. ;
  %applyTransformation;

  * Create the dataset that would be used for analysis. ;
  data work.analydata_tmp;
    set work.preprocess_tmp2;
  run;

  * Delete temporary files. ;
  proc datasets nolist library=work;
    delete
      preprocess_tmp preprocess_tmp1 preprocess_tmp2;
  run;
  quit; 

%mend  preprocess;


%macro applyExclusion;
/*******************************************************************************
  Apply exclusion, as defined by the user.
  - Otherwise, no exclusion will be applied.
*******************************************************************************/

  * Keep row numbers of the dataset (in case needed). ;
  data work.preprocess_tmp1;
    set work.preprocess_tmp;
    
    rownum = _n_;   
  run;

  * Exclude record(s). ;
  data work.preprocess_tmp1;
    set work.preprocess_tmp1;

    %if        %upcase(&NET2SAS_exclSubjectChekBox) = CHECKED 
        and    %upcase(&NET2SAS_exclBlockChekBox)   = CHECKED  %then
    %do;
      if ( (&exclSubjectList) or (&exclBlockList) )  then delete; 
    %end;
    %else %if  %upcase(&NET2SAS_exclSubjectChekBox) = CHECKED  %then
    %do;
      if &exclSubjectList then delete; 
    %end;
    %else %if  %upcase(&NET2SAS_exclBlockChekBox)  = CHECKED   %then
    %do;
      if &exclBlockList then delete; 
    %end;
  run;

%mend  applyExclusion;


%macro applyTransformation;
  /*******************************************************************************
    Apply transforamtion, as defined by the user. 
    - Otherwise, the application uses the default value "NONE".  
  *******************************************************************************/

  data work.preprocess_tmp2;
    set work.preprocess_tmp1 (drop= rownum);

    %if       %upcase(&transf) =POW2  %then 
    %do;  transf_response =response**2;
    %end;
    %else %if %upcase(&transf) =INV   %then 
    %do;  
      if response > 0   then 
          transf_response =1/response;
    %end;
    %else %if %upcase(&transf) =SQRT  %then 
    %do;  
      if response >= 0  then 
          transf_response =sqrt(response);
    %end;
    %else %if %upcase(&transf) =LOG   %then 
    %do;  
      if response > 0      then 
          transf_response =log(response);
    %end;
    %else 
    %do;
          transf_response =response;
    %end;
 
  run;

%mend  applyTransformation;

%preprocess;
