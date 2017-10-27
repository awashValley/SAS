%*** obfuscate usubjid in all data sets *** ;
%macro usubjid ;
	%local i v dsnlist;
	%let dsnlist=AE CM CO DM DS LB MH QS SC SUPPAE SUPPCM SUPPDM SUPPDS
	SUPPLB SUPPMH SV VS X9 OLDMH OLDSUPPMH ;
	%let i=1;
	%let v=%scan(&dsnlist.,&i,%str( ));
	
	%do %while (&v. ne);
		%if %sysfunc(exist(sdtmorig.&v.)) %then %do ;
			data sdtm.&v.;
				set sdtmorig.&v.;
				
				usubjid = put( usubjid, $usubjid. ) ;
				
				%if &v. eq DM %then %do ;
					subjid = put(input(scan(usubjid,2,'.'),best.),best. - L);
				%end ;
			run;
		%end ;
		
		%let i=%eval(&i.+1);
		%let v=%scan(&dsnlist.,&i,%str( ));
	%end ;
%mend usubjid;
%usubjid;

******************************************************************;
** Appendix 4 Example code to obfuscate subject study dates       ;
******************************************************************;
proc format;
	invalue mon
	'JAN'=1
	'FEB'=2
	'MAR'=3
	'APR'=4
	'MAY'=5
	'JUN'=6
	'JUL'=7
	'AUG'=8
	'SEP'=9
	'OCT'=10
	'NOV'=11
	'DEC'=12;
run;

%*** convert partial character dates to iso8601 format -- outputs character variable new&VAR. *** ;
%macro iso8601(var=ADIAGD_);
	length &var._tmpday &var._tmpmo $ 2 &var._tmpyr $ 4 new&var. $ 10;
	&var._tmpyr = put( input( substr(&var.,6), ?? best. ), 4. -L ) ;
	&var._tmpmo = put( input( upcase(substr(&var.,3,3)), ?? mon. ),
	z2. -L) ;
	&var._tmpday = put( input( substr(&var.,1,2), ?? best. ), z2. -L);
	new&var. = catx('-',&var._tmpyr,&var._tmpmo,&var._tmpday) ;
	drop &var._tmp: ;
%mend iso8601;


options missing=' ' ;

data ad ;
	set dmwork.ad(keep=studyid subjid ADIAGD_ ADHISPSC ADHISOR
	FSYMPD_) ;
	usubjid = put( catx('.', studyid, put( subjid, z7. -L ) ),
	$usubjid. -L ) ;
	%*** create new dates in ISO8601 format *** ;
	%iso8601(var=ADIAGD_) ;
	%iso8601(var=FSYMPD_) ;
run ;

%let stdt=01JUL; %* the base date ;

data dm ;
	set sdtm.dm ;
	rfstart = input(rfstdtc,yymmdd10. ) ;
	stdt = input("&stdt."||put(year(rfstart),best. -L), date9.);
	rfend = input(rfendtc,yymmdd10. ) ;
	stdiff = rfstart - stdt ; %*** offset days for creating new dates
	*** ;
	stdtc = put( stdt, date9. -L ) ;
	rfendt = put( rfend - stdiff, date9. -L ) ;
	%iso8601(var=stdtc);
	%iso8601(var=rfendt);
	rfstdtc = newstdtc ;
	rfendtc = newrfendt ;
	format stdt rfstart rfend date9. ;
	drop stdtc rfendt /*day: mo: yr:*/ new: stdt ;
run ;


%macro dummydates(dsetin=, vars=rfendtc, basedate=rfstdtc);
	proc sort data = sdtm.&dsetin. out = &dsetin._tmp;
		by usubjid ;
	run ;
	
	data sdtm.&dsetin. ;
		length timepart $20 ;
		merge dm(keep=usubjid &basedate. stdiff) &dsetin._tmp(in=_ctrl_);
		%*** merge the base date and offset days to each data set for calculating new dates *** ;
		by usubjid ;
		if _ctrl_ ;
		%local i v ;
		%let i = 1;
		%let v=%scan(&vars.,&i.,%str( )) ;
		%do %while (&v. ne );
			%** create a complete date then offset *** ;
			if not missing( &v. ) then do ;
				varlen = length(trim(left(&v.)));
				timepart = ' ' ;
				drop varlen timepart ;
				%*** date and time e.g. 2008-03-07T11:00 *** ;
				if varlen gt 10 then do ;
					&v._ = put( input(substr(&v.,1,10),yymmdd10. ) -
					stdiff, date9. -L ) ;
					timepart = substr(&v.,11) ;
				end ;
				
				%*** date only e.g. 2008-03-07 *** ;
				else if varlen eq 10 then
					&v._ = put( input(&v.,yymmdd10. ) - stdiff, date9. -L) ;
				%*** partial date day and month e.g. 2008-03 *** ;
				else if length(trim(left(&v.))) eq 7 then
					&v._ = put( input(left(trim(&v.))||'-15',yymmdd10. ) - stdiff, date9. -L ) ;
				%*** partial date year only e.g. 2008 *** ;
				else if length(trim(left(&v.))) eq 4 then
					&v._ = put( input(left(trim(&v.))||'-07-01',yymmdd10.) - stdiff, date9. -L ) ;
				%iso8601(var=&v._);
				%*** retain old value for QC purposes *** ;
				old&v.=&v.;
				%*** capture same level of precision that was supplied ***;
				if varlen lt 10 then
					&v. = substr( left(new&v._), 1, varlen ) ;
				else &v. = new&v._ ;
				%*** attach time portion if exists *** ;
				if not missing( timepart ) then
					&v. = trim(left(&v.)) || left( timepart ) ;
			end ;
			
			*format stdt date9. ;
			drop new: &v._;
			%let i = %eval(&i.+1);
			%let v = %scan(&vars.,&i.,%str( )) ;
		%end ;
	
		drop stdiff rfstdtc old: ;
	
	run ;
	
%mend dummydates;

%dummydates(dsetin=cm,vars=CMSTDTC CMENDTC);
%dummydates(dsetin=sc,vars=SCDTC);
%dummydates(dsetin=qs,vars=QSDTC);
%dummydates(dsetin=ds,vars=DSSTDTC);
%dummydates(dsetin=lb,vars=LBDTC);
%dummydates(dsetin=mh,vars=MHDTC MHSTDTC);
%dummydates(dsetin=sv,vars=SVSTDTC SVENDTC);
%dummydates(dsetin=vs,vars=VSDTC);
%dummydates(dsetin=ae,vars=AESTDTC AEENDTC);

data sdtm.dm ;
	set dm(drop=stdiff rfstart rfend);
run ;
