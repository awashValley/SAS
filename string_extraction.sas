/* [Tue, 19-Sep-2017]. Extract before and after delimiter. */
   DATA _files;
      LENGTH ext $8 filename name $800 ;
      filename="&fname";                  /* e.g., abc_dyx.csv */
      ext=scan(filename,-1,'.');          /* to extract string after dot*/
      name=scan(filename,1,'.');          /* to extract string before dot*/
    RUN;
