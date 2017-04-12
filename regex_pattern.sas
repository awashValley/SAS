* [MON 22AUG2016]. Regular expression using PRXMATCH. ;
  IF PRXMATCH("/^\d\d\d\d-\d\d-\d\d/",&refdate) AND 
     PRXMATCH("/^\d\d\d\d-\d\d-\d\d/",&date)
  THEN DO;

    /* something to be done */

  END;
  ELSE DO;
    /* something to be done */
  END;

/* Regular expression example. */
/* SOURCE: http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a002295969.htm */

data test;
  text = "lib1.xyz=lib2.abc blah blahh lib3.fgh=lib4.ijk"; 
  ptnID = prxparse('/(\w+)\.(\w+)/');     /* since dot is a special character, you need to escape it. */
  
  IF PRXMATCH(ptnID, text) THEN 
  DO;
    call prxposn(ptnID, 1, position, length);
    first_wrd = substr(text, position, length);
    output;
    
    call prxposn(ptnID, 2, position, length);
    second_wrd = substr(text, position, length);
    output;
  END;
  
run;

data _null_;
   patternID = prxparse('/(\d\d):(\d\d)(am|pm)/'); 
   text = 'The time is 09:56am.';

   if prxmatch(patternID, text) then do;
      call prxposn(patternID, 1, position, length);
      hour = substr(text, position, length);
      call prxposn(patternID, 2, position, length);
      minute = substr(text, position, length);
      call prxposn(patternID, 3, position, length);
      ampm = substr(text, position, length);

      put hour= minute= ampm=;
      put text=;
   end;
run;
