/* [10-jan-2018]. Create a cross tabulation in a report. */
proc report data=work.group_means2 nowd;
  title 'Average (standard deviation) by group and time.';
  column ('Group' &group.) ('Time' &time.), (avg_sd);
  define group / group ' ';
  define time / across ' ';
  define avg_sd / ' ' group;
quit;
