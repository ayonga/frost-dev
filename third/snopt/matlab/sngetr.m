% function  rvalue = sngetr( option )
%     The REAL-VALUED optional parameter defined by the string "option"
%     is returned.
%
%     For a description of all the optional parameters, see the
%     snopt documentation.
%
function rvalue = sngetr( option )

getoptionR = 8;
rvalue = snoptmex( getoptionR, option );
