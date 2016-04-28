
* [Thur 28Apr2016]. Preprocessing, i.e., exclusion and transformation.;

%macro preprocess;
/*******************************************************************************
  Preprocess imported dataset.
*******************************************************************************/

  * Get imported dataset, only parameter of interest is kept. ;
  data work.preprocess_tmp;
    set work.combined_ds (keep   =&keep_vars_wtpars &parameter
                          rename =(&parameter=response) );
  run;

  * Create label for a selected parameter. ;
  %if       %upcase(&parameter) = abcd %then
  %do;
    %let label_parameter =%str(abcd efg);
  %end;
  %else %if %upcase(&parameter) = xyz %then
  %do;
    %let label_parameter =%str(xyza);
  %end;

  * Apply data exclusion. ;
  %applyExclusion;

  * Apply transformation. ;
  %applyTransformation;

  * Create analysis dataset. ;
  data work.analydata_tmp;
    set work.preprocess_tmp2;
  run;

  * Delete temporary datasets. ;
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

  * Keep row numbers, in case needed. ;
  data work.preprocess_tmp1;
    set work.preprocess_tmp;
    
    rownum = _n_;   
  run;

  * Exclude record(s). ;
  data work.preprocess_tmp1;
    set work.preprocess_tmp1;

    %if        %upcase(&frontEnd2SAS_exclSubjectChekBox) = CHECKED 
        and    %upcase(&frontEnd2SAS_exclBlockChekBox)   = CHECKED  %then
    %do;
      if &exclSubjectList then delete; 
      if &exclBlockList   then delete; 
    %end;
    %else %if  %upcase(&frontEnd2SAS_exclSubjectChekBox) = CHECKED  %then
    %do;
      if &exclSubjectList then delete; 
    %end;
    %else %if  %upcase(&frontEnd2SAS_exclBlockChekBox)   = CHECKED   %then
    %do;
      if &exclBlockList   then delete; 
    %end;
  run;

%mend  applyExclusion;


%macro applyTransformation;
  /*******************************************************************************
    Apply transforamtion, as defined by the user. 
    - Otherwise, no transformation will be applied.  
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
