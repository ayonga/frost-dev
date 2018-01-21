% function snprint( filename )
%     Causes SNOPT to write detailed information about its progress
%     to the file named in "filename."
%
%     "snprint off" causes SNOPT to stop writing to filename,
%     and close the file.
%
%     Note that until the file has been closed, it may not contain
%     all of the output.
%
%     snprint serves the same function as snprintfile.
%
%     WARNING:  Do not use snset() or snseti() to set the print file.

function snprint( filename )

%openprintfile  = snoptmex( 0, 'SetPrintFile'   );
%closeprintfile = snoptmex( 0, 'ClosePrintFile' );

openprintfile  = 10;
closeprintfile = 12;

if strcmp( filename, 'off' )
  snoptmex( closeprintfile );
elseif strcmp( filename, 'on' )
  snoptmex( openprintfile, 'print.out' );
else
  snoptmex( openprintfile, filename );
end
