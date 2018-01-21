% function sqsetr( option, rvalue )
%     Sets the optional REAL-VALUED parameter defined by the
%     string "option" to the value  rvalue.
%
%     For a description of all the optional parameters, see the
%     sqopt documentation.
%
%     Do not try to set the unit number of the summary or print file.
%     Use the MATLAB functions sqsummary and sqprintfile instead.
%
function sqsetr( option, rvalue )

setoptionR = 4;
sqoptmex( setoptionR, option, rvalue );
