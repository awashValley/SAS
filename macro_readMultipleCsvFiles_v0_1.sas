%macro read_raw_data(rawFileNames =,
                     dropvars     =);

  * Suppress ODS results. ;
  ods results off;

  * Define data directory. ;
  %let data_dir =%str(...);

  * Get number of selected files. ;
  %let numOfFiles =%sysfunc(countw(&rawFileNames, ' '));

  * Import the first dataset among the selected list. ;
  %let fname1 =%scan(&rawFileNames, 1, %str( ));

  filename indata1 "&data_dir.\&fname1";

  data work.combined_ds (drop=x:);
    infile indata1 dsd dlm="," missover lrecl=32767 firstobs=2;
  	length x1 x2 $ 200
		    var1 8
		    var2 $1
		    var3 8 
    input x1 $ var1 x2 $ var2 $ var3;
  run;

  * Combine all selected datasets. ;
  %if &numOfFiles > 1  %then
  %do;

    %do i=2 %to &numOfFiles;

      %let fnamei = %scan(&rawFileNames, &i, %str( ));

      filename indatai "&data_dir.\&fnamei";

      data work.one (drop=x:);
        infile indatai dsd dlm="," missover lrecl=32767 firstobs=2;
  	    length x1 x2 $ 200
					var1 8
					var2 $1
					var3 8 
				input x1 $ var1 x2 $ var2 $ var3;
			run;

      proc append base= work.combined_ds 
                  data= work.one force; 
      run;
    
    %end;
  %end;
  
  * Sort imported dataset. ;
  proc sort data=work.combined_ds;
    by var1;
  run;

  * Delete temporary dataset(s). ;
  proc datasets nolist library=work;
  delete
    one;
  run;
  quit;

%mend  read_raw_data;
