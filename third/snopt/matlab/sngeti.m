% function  ivalue = sngeti( option )
%     The  optional INTEGER-valued parameter defined by the
%     string "option" is returned.
%
%     For a description of the optional parameters, see
%     the snopt documentation.
%
function ivalue = sngeti( option )

getoptionI = 7;
ivalue = snoptmex( getoptionI, option );
