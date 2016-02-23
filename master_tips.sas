/* [22FEB2016]
  1. %put ERROR: Excel file was not able to be read...
  2. Specify the libname "work" always for documentation reason, e.g., "work.dataxyz".
  3. Use the potential of Excel program for checking if SAS properly reads your data ("handig").
  4. Try your best to make your macro generic as possible.
  5. Macro parameters: [M] for mandatory and [O] for optional
  6. PROC compare
*/

/* [23FEB2016] The "retain" statement holds the previous value of a variable. It orders the variable to first position */
   data work.test;
     retain counter;
     set sashelp.class;
     if _n_ = 1 then counter = 0;
     if sex = "M" then counter = counter + 1;   
   run;
   
/* [23FEB2016] The "compress" function: 
               - removes all white spaces (leading, back, and intermidiate). Refer "Strip" vs "compress";
               - doesn't remove other symbols except white space. Howver, it has an argument for removing other symbols
*/
  * old-fashioned. ;
  studyid=compress(translate(studyid, "  ", ".-"));
  
  * efficient way. ;
  studyid=compress(studyid, " .-"));

  
