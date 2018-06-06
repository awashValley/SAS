/* [Wed, 06-jun-2018]. Data driven integration of HTML/JS/CSS source codes into SAS */
proc sort data =&dsin.
	  out  =work.output_report_srt;

  by index_counter;
run;

data _null_;
  length code body_html_main_ddriven $ 20000;
  set work.output_report_srt end=last;
  retain code body_html_main_ddriven;

  by index_counter;

  code = catx(" ", 
			  '<div class="datarow"', cats(" id=", quote(cats("row", strip(put(index_counter, best.))))),'>
			<div class="cell index_number">', index_counter ,'</div>
			<div class="cell variable">', variable, '</div>
			<div class="cell label">', label, '</div>
			<div class="cell type">', type, '</div>
			<div class="cell length">', length, '</div>
			<div class="cell details">', details_short, '</div>
			<div class="cell expand"', cats(" id=", quote(cats("row", strip(put(index_counter, best.)), "toggle"))), 'onclick="toggleDisplay(this.parentNode.id)">+</div>    
		      </div>
		      <div class="datarow hidden"', cats(" id=", quote(cats("row", strip(put(index_counter, best.)), "details"))),'>
			<div class="cell index_number">&nbsp;</div>
			<div class="cell variable">&nbsp;</div>
			<div class="cell label">&nbsp;</div>
			<div class="cell type">&nbsp;</div>
			<div class="cell length">&nbsp;</div>
			<div class="cell details">', cats(details_long, "<br>", details_long_addFreq), '</div>
			<div class="cell expand">&nbsp;</div>    
		      </div>'
		 );

  if   _n_ = 1 then body_html_main_ddriven = code;
  else              body_html_main_ddriven = catx("  ", 
					      body_html_main_ddriven, code);

  if last then do;
    call symput('body_html_main_ddriven', body_html_main_ddriven);
/*		put body_html_main_ddriven;*/
	output;
  end;
run;

/* create HTML header / footer macro variables. */
data _null_;
  length header_html body_html footer_html
     body_html_header body_html_main_ddriven body_html_main
     body_html html_report $ 30000;

  header_html = catx(" ", 
'<!DOCTYPE html>
	<html lang="en">
	  <head>
	    <title>Data Set Contents</title>
		<style type="text/css">
		/*Color Scheme with #006495 #004C70 #0093D1 #F2635F #F4D00C #E0A025*/
			body {font-family: Roboto; font-size: 10pt;}
			.info {display:table; position: relative; left: 50px}
			.metarow {display:table-row}
			.propname {display:table-cell; text-align: right; width: 50px; padding: 3px 10px 3px 5px; font-size: 8pt; color: #999}
			.propvalue {display:table-cell; font-size: 8pt; color: #000}
			.large {font-size: 16pt; font-weight: bold; color: #000}

			.datadef {display:table; position:border-collapse:separate;border-spacing:2px}
			.datarow {clear: left; display:table-row}
			.cell {display:table-cell; background-color: #eee; padding: 3px 10px 3px 5px}
			.index_number {width: 20px}
			.variable {width: 250px}
			.label {width: 50px}
			.type {width: 50px}
			.length {width: 150px}
			.details {width: 350px; background-color: #ddd}
			.expand {width: 20px; text-align: center; font-weight: bold}
			.hidden {display: none; border:1px solid black;}
			.h {background-color: #004C70; color: #fff; font-weight: bold}
      </style>
	  </head>
	  <body>
  <script type="text/javascript">
			function toggleDisplay(id) {
				detailid = id + "details";
				toggleid = id + "toggle";

				if(document.getElementById(detailid).style.display != "table-row") {
					document.getElementById(detailid).style.display = "table-row";
					document.getElementById(toggleid).innerHTML = "&ndash;";
				} else {
					document.getElementById(detailid).style.display = "none";
					document.getElementById(toggleid).innerHTML = "+";
				}
			}
	 </script>');
/*	  put header_html;*/

  * Define HTML body header. ;
  body_html_header = 
      '<div class="info">
      <div class="metadata">
	<div class="metarow">
	  <div class="propname">Name:</div>
	  <div class="large propvalue">CLASS</div>
	</div>
	<div class="metarow">
	  <div class="propname">Location:</div>
	  <div class="propvalue">C:\users\jhz\Desktop</div>
	</div>
	<div class="metarow">
	  <div class="propname">Size:</div>
	  <div class="propvalue">1,483 KB</div>
	</div>
	<div class="metarow">
	  <div class="propname">Saved:</div>
	  <div class="propvalue">2018-05-24T12:51:39</div>
	</div>
      </div>
    </div>
<div class="datadef" id="container">
      <div class="datarow" >
	<div class="h cell index_number">&num;</div>
	<div class="h cell variable">Variable</div>
	<div class="h cell label">Label</div>
	<div class="h cell type">Type</div>
	<div class="h cell length">Length</div>
	<div class="h cell details">Contents</div>
	<div class="h cell expand">&nbsp;</div>    
     </div>';

  body_html_main_ddriven = symget('body_html_main_ddriven');
/*	  put body_html_main_ddriven;*/

  body_html_main = strip(body_html_header) || 
		   strip(body_html_main_ddriven);
/*  put body_html_main;*/
  body_html = body_html_main;
/*  put body_html;*/

  footer_html = 
    '</body>
	</html>';

  html_report = strip(header_html) || 
		strip(body_html)   || 
		strip(footer_html);
/*	  put html_report;*/

  call symput('html_report', html_report);
run;

data _null_;
  file "&dir_html_file.\&domain._dataset_overview.html";

  length html_report $ 20000;
  html_report = symget('html_report');
  put html_report;
run;
