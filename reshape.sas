
/* [Thur, 21-Sep-2017].  collapse multiple rows into one. */
DATA work.metadata_header3 (DROP = _header_xls header_txt);
  LENGTH header_xls format_var $ 2000;
  SET work.metadata_header2;
  RETAIN header_xls format_var;
  
  BY category_num;
  
  IF FIRST.category_num THEN DO;
    header_xls = _header_xls;
    format_var =  header_txt;
  END;
  ELSE IF NOT FIRST.category_num THEN DO;
    header_xls = CATX(' ', header_xls, _header_xls);
    format_var = CATX(' ', format_var,  header_txt);
  END;
  
  IF LAST.category_num THEN OUTPUT;
RUN;

/* [Mon, 04-jun-2018]. Reshape - efficient (i.e., use "_N_=1" condition, instead of "first.count") */
proc sort data=work.stat_char01 out=work.stat_char02;
  by count;
run;

data work.details_long;
  length stat_long details_long $ 200;
  set work.stat_char02 end=last;
  retain details_long stat_long;

  by count;

  * Combine values. ;
  stat_long = catx("  ", &sel_var., 
                         cats("(", count, "x)"));

  * Create long details. ;
  if   _N_=1 then details_long = stat_long;
  else            details_long = catx(" ", details_long, stat_long);
 
  if last then output;
run;

/* [Wed, 06-jun-2018]. How to concatenate very wide set of strings? */
/* - IMPORTANT function is STRIP (see line 94 - 96) and the length statement does also matters (see line 51). */
data _test;
/*data _null_;*/
  length header_html body_html footer_html 
         body_html_tblHeader body_html_tblFooter /*$ 2000*/
         body_html_tblBody body_html_tbl body_html html_report $ 30000;

  header_html = 
	'<!DOCTYPE html>
	<html lang="en">
	  <head>
	    <title>Data Set Contents</title>
	    <link rel="stylesheet" href="style.css">
	  </head>
	  <body>';
  
  body_html_tblHeader = 
	'<table>
      <col width="45%">
      <col width="55%">
      <tr>
        <td class="top"><h1>DATAPATH.LB </h1></td>
        <td class="gray"><i>  </i><br>Created: 23MAY18:16:57:10         <br> # obs : 64432 <br>Keys : </td>
      </tr>
    </table>
    <table class="sortable" id="variableTable">
      <col width="2%">
      <col width="8%">
      <col width="25%">
      <col width="6%">
      <col width="5%">
      <col width="8em">
      <col width="*">
      <thead>
      <tr>
         <th>#</th><th>Variable</th><th>Label</th><th>Type</th><th>Length</th>
         <th onClick="toggleAll(this)" onMouseOver="togglePointer(this)" class="but"><div class="media">+</div></th><th>Contents</th>
      </tr>
      </thead>
      <tbody>';

  body_html_tblBody = symget('body_html_tblBody');
/*  put body_html_tblBody;*/

  body_html_tblFooter = 
	'</tbody>
     </table>';

  body_html_tbl =  strip(body_html_tblHeader) || 
                   strip(body_html_tblBody)   || 
                   strip(body_html_tblFooter);
  put body_html_tbl;
  body_html     = body_html_tbl;
/*  put body_html;*/

  footer_html = 
    '<script type="text/javascript" src="javascript.js"></script>
	</body>
	</html>';

  html_report = header_html || body_html || footer_html;
/*  put html_report;*/

  call symput('html_report', html_report);
run;
