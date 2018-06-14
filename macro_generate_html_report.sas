%macro generate_html_report (dsin               =,
                             domain             =,
                             file_path_html_out =);

	* create html table contents.;
	proc sort data =&dsin.
	          out  =work.output_report_srt;

	  by index_counter;
	run;

	* ------------------------------------ ;
	* Create HTML header and footer part.  ;
	* ------------------------------------ ;
	* Define a filename for HTML output file. ;
	filename rw_html "&file_path_html_out.\&domain._dataset_overview.html";

	data _null_;
	  file rw_html;
	  length header_html body_html_header $ 20000;
	  set work.output_report_srt end=last;

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
				.format {width: 150px}
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

	  body_html_header = 
        catx(" ", 
		    '<div class="info">',
	            '<table>
			      <tr>
			        <td class="top"><h2>', cats(libname, ".", memname), '</h2></td>
					<td class="gray"></td>
			        <td class="gray"><i>  </i><br>Created: ', file_created, '<br> # obs : ', num_of_records, '<br>Keys : </td>
			      </tr>
			    </table>',
			'</div>',
			'<div class="datadef" id="container">
			  <div class="datarow" >
			    <div class="h cell index_number">&num;</div>
			    <div class="h cell variable">Variable</div>
			    <div class="h cell label">Label</div>
			    <div class="h cell type">Type</div>
			    <div class="h cell length">Length</div>
			    <div class="h cell format">Format</div>
			    <div class="h cell details">Contents</div>
			    <div class="h cell expand">&nbsp;</div>    
			 </div>'
            );

	  if last then do;
	    * Output HTML header code. ;
	    put header_html;

	    * Output HTML body header code. ;
	    put body_html_header;
	  end;
	run;
	
	* ------------------------------------ ;
	* Create HTML data-driven body part.   ;
	* ------------------------------------ ;
	data _null_;
	  file rw_html mod;     * The "mod" option is used to append new data to the raw file. ;
	  length code $ 20000;
	  set work.output_report_srt end=last;
	  retain code;

	  by index_counter;

	  code = catx(" ", 
				  '<div class="datarow"', cats(" id=", quote(cats("row", strip(put(index_counter, best.))))),'>
			        <div class="cell index_number">', index_counter ,'</div>
			        <div class="cell variable">', variable, '</div>
			        <div class="cell label">', label, '</div>
			        <div class="cell type">', type, '</div>
			        <div class="cell length">', length, '</div>
			        <div class="cell format">', format, '</div>
			        <div class="cell details">', details_short, '</div>
			        <div class="cell expand"', cats(" id=", quote(cats("row", strip(put(index_counter, best.)), "toggle"))), 'onclick="toggleDisplay(this.parentNode.id)">+</div>    
			      </div>
			      <div class="datarow hidden"', cats(" id=", quote(cats("row", strip(put(index_counter, best.)), "details"))),'>
			        <div class="cell index_number">&nbsp;</div>
			        <div class="cell variable">&nbsp;</div>
			        <div class="cell label">&nbsp;</div>
			        <div class="cell type">&nbsp;</div>
			        <div class="cell length">&nbsp;</div>
			        <div class="cell format">&nbsp;</div>
			        <div class="cell details">', details_long_addFreq, '</div>
			        <div class="cell expand">&nbsp;</div>    
			      </div>'
			 );

	  * Output data-driven HTML body code. ;
	  put code;

	  if last then do;
	    footer_html = 
	      '</body>
		  </html>';

		* Output HTML footer code. ;
		put footer_html;
	  end;
	run;

%mend generate_html_report;
