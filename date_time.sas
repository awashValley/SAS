/* DATETIME */
%LET run_dt = %SYSFUNC(datetime(),datetime.);
%LET log_dt = %SYSFUNC(tranwrd(%bquote(&run_dt),%STR(:),%STR(_)));

%PUT run_dt: &run_dt;   /* run_dt: 19OCT16:11:48:56 */
%PUT log_dt: &log_dt;   /* log_dt: 19OCT16_11_48_56 */
