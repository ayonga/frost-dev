%function sqsummary( filename )
%     Causes SQOPT to write summarized information about its progress
%     to the file named in "filename".
%
%     "sqsummary off" causes SQOPT to stop writing to filename,
%     and close the file.
%
%     Note that until the file has been closed, it may not contain
%     all of the output.
%
%     WARNING:  Do not use sqset() or sqseti() to set the summary file.
function sqsummary( filename )

opensummary  = 11;
closesummary = 13;

if strcmp( filename, 'off' )
  sqoptmex( closesummary );
else
  sqoptmex( opensummary, filename );
end
