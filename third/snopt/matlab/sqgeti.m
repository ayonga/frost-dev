% function  ivalue = sqgeti( option )
%     The  optional INTEGER-valued parameter defined by the
%     string "option" is assigned to rvalue.
%
%     For a description of the optional parameters, see
%     the sqopt documentation.
%
function ivalue = sqgeti( option )

getoptionI = 7;
ivalue = sqoptmex( getoptionI, option );
