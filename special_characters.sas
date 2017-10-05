/* [Thur, 05-Oct-2017]. Remove carriage return and linefeed characters */
/*                      - SOURCE (for the code): http://studysas.blogspot.co.uk/2011/10/how-to-remove-carriage-return-and.html*/
/*                      - SOURCE (about special characters): http://www.asciitable.com/ */
var1 = UPCASE(COMPRESS(var1_src,'0D0A'x));   /* Note: this value contains carriage return and linefeed characters. Remove these before copy the value. */
