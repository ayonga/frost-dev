% function sqprint( filename )
%     Causes SQOPT to write detailed information about its progress
%     to the file named in "filename."
%
%     "snprint off" causes SQOPT to stop writing to filename,
%     and close the file.
%
%     Note that until the file has been closed, it may not contain
%     all of the output.
%
%     sqprint serves the same function as sqprintfile.
%
%     WARNING:  Do not use sqset() or sqseti() to set the print file.

function sqprint( filename )

%openprintfile  = sqoptmex( 0, 'SetPrintFile'   );
%closeprintfile = sqoptmex( 0, 'ClosePrintFile' );

openprintfile  = 10;
closeprintfile = 12;

if strcmp( filename, 'off' )
  sqoptmex( closeprintfile );
elseif strcmp( filename, 'on' )
  sqoptmex( openprintfile, 'print.out' );
else
  sqoptmex( openprintfile, filename );
end
