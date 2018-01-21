%function sqscreen( filename )
%    Regulates output to the terminal.  Will print major iteration
%    information identical to that printed to a summary file if set.
%    Thus options that effect summary output may affect information
%    printed to the screen.  Option is off by default.  To turn on
%    the screen output, type:
%    >> sqscreen on
%    to turn the screen output back off, type:
%    >> sqscreen off
%
%    NOTE:  A summary file need not be set to use the screen option.
function sqscreen( filename )

screenon     = 15;
screenoff    = 16;

if strcmp( filename, 'on' )
  sqoptmex( screenon );
elseif strcmp( filename, 'off' )
  sqoptmex( screenoff );
end
