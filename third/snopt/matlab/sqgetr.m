% function  rvalue = sqgetr( option )
%     The REAL-VALUED optional parameter defined by the string "option"
%     is assigned to rvalue.
%
%     For a description of all the optional parameters, see the
%     sqopt documentation.
%
function rvalue = sqgetr( option )

getoptionR = 8;
rvalue = sqoptmex( getoptionR, option );
