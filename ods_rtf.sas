
* [25FEb2016] The ODS option "startpage". ;
  /* result 1. */
  ods rtf file="&path\out1.rtf" startpage=no;
  
  title1 'blah blah.';
  title2 ' ';
  title3 'Top table: blah blah.';
  title4 'Bottom table: blah blah.';
  
  /* do something. */
  
  /* result 2. */
  ods rtf startpage=yes;
  
  title1 'blah blah.';
  title2 ' ';
  title3 'Top table: blah blah.';
  title4 'Bottom table: blah blah.';
  
  /* do sth. */
  
  ods rtf startpage=no;
  
  /* do something */
  
  ods rtf close;
