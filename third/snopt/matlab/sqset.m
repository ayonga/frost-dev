% function sqset( option )
%     Sets a optional parameter of sqopt. The string "option" will be read
%     by sqopt. If the string contains a setting that sqopt understands,
%     sqopt will set internal parameters accordingly. For a description of
%     available parameters, please see the sqopt documentation.
%
%     Do not try to set the unit number of the summary or print file.
%     Use the MATLAB functions sqsummary and sqprintfile instead.
%
function sqset( option )

setoption = 2;
sqoptmex( setoption, option );