/* [Wed, 06-jun-2018]. Data driven integration of HTML code in SAS */
data code;
  length code body_html_tblBody $ 20000;
  set work.output_report_srt end=last;
  retain code body_html_tblBody;

  by index_counter;

  code = catx(" ", 
    '<tr>
        <td class="name">', index_counter, '</td>
        <td class="name">', variable, '</td>
        <td class="cells">', label, '</td>
        <td class="cells">', type, '</td>
        <td class="cells">', length, '</td>
        <td class="but" onclick="toggleSample(this)" onMouseOver="togglePointer(this)" id="', 
            cats("TG000", index_counter), '><div class="media">+</div></td>
       <td class="cells">', details_short, cats("<br>", details_long),
       '<div id="', cats("TTG000", index_counter), 'style="display:none" class="sample">',
	        details_long_addFreq,
	   '</div></td>
     </tr>');

  if   _n_ = 1 then body_html_tblBody = code;
  else              body_html_tblBody = catx("  ", body_html_tblBody, code);

  if last then do;
    call symput('body_html_tblBody', body_html_tblBody);
	put body_html_tblBody;
	output;
  end;
run;

/* create HTML header / footer macro variables. */
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
