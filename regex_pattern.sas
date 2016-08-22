* [MON 22AUG2016]. Regular expression using PRXMATCH. ;
  IF PRXMATCH("/^\d\d\d\d-\d\d-\d\d/",&refdate) AND 
     PRXMATCH("/^\d\d\d\d-\d\d-\d\d/",&date)
  THEN DO;

    /* something to be done */

  END;
  ELSE DO;
    /* something to be done */
  END;
