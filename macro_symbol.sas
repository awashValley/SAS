
/* Source:        PharmaSUG 2014 - Paper CC12. 
   Accessed Date: 08APR2016
   Modified:      11APR2016
*/

%macro symbol(data  =,
              group =,
              para  =);

/*  proc sort data=&data nodupkey out=work.out;*/
/*    by &group;*/
/*  run;*/

  proc sort data=&data out=work.out;
    by &group;
  run;

/*  data work.out1;*/
/*    set work.out;*/
/**/
/*    length v_i $1.;*/
/**/
/*    by &group;*/
/*    if first.&group then seq+1;*/
/*  run;*/

  *Use ‘call execute’ to conditionally process codes while taking data step values to 
   apply the most often used symbol parameters(c,i,v,l,f,mode,w,h).some parameters were 
   set with defaults, if &para is defined differently and executed, some parameters in 
   data step may be overwrriten; 
/*  data _null_;*/
/*    length c v i f $100.;*/
/*    set work.out1;*/
/**/
/*    w =1; */
/*    h =1; */
/*    i ='std1tjm'; */
/*    f ='SWISS'; */
/*    l =SEQ; */
/*    c ='_STYLE_'; */
/*    v =''; */
/*    &para.; */
/**/
/*    call execute( "symbol"||strip(put(seq,best.))||"  */
/*                  c='"||strip(c)|| "'  */
/*                  v='"||strip(v)|| "' */
/*                  L=" ||strip(put(l,best.))||"  */
/*                  i=  " ||STRIP(i)||  "  */
/*                  font='"||strip(f)||" ' */
/*                  mode=include"||" */
/*                  width="||strip(put(w,best.))|| "  */
/*                  h="||strip(put(h,best.)) ||" ;"  ); */
/*  run;*/

  data _null_;
    length i f w h $20. code $100;
    set work.out;

    i ='join';
    f ='verdana';
    w ='1.5';
    h ='1';

    code =cats(catx(" ", 
                    cats("symbol",strip(put(&group,best.)))
                   ,cats("v=",strip(shape))
                   ,cats("c=",strip(color))
                   ,cats("l=",strip(put(line,best.)))
                   ,cats("i=", strip(i))
                   ,cats("w=",strip(w))
                   ,cats("h=",strip(h)) ), ' ;');

    call execute(code);
  run;

%mend  symbol;
