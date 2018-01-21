% function sqseti( option, ivalue )
%     Sets the INTEGER-VALUED optional parameter defined by the
%     string "option" is assigned to rvalue.
%
%     For a description of all the optional parameters, see the
%     sqopt documentation.
%
%     Do not try to set the unit number of the summary or print file.
%     Use the MATLAB functions sqsummary and sqprintfile instead.
%
function sqseti( option, ivalue )

setoptionI = 3;
sqoptmex( setoptionI, option, ivalue );
