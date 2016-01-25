
* How can I combine multiple rows to a single row? ;
  data have;
    input id $ year $ v1 v2 v3;
    cards;
    1	1999	.	270	.
    1	1999	.	.	350
    1	1999	.	.	.
    2	2000	20	.	.
    2	2000	.	300	.
    2	2000	.	.	320
    3	2001	.	122	.
    3	2001	.	.	.
    3	2001	.	.	500
  ;
  proc print; run;
  
  data want;
    update have(obs=0) have;
    by id year;
  run;
  proc print; run;
