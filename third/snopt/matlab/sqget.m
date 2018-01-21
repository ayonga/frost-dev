% function  set = sqget( option )
%     The  optional INTEGER-valued parameter defined by the
%     string "option" is assigned to rvalue.
%
%     For a description of the optional parameters, see
%     the sqopt documentation.
%
function set = sqget( option )

getoption = 5;
set = sqoptmex( getoption, option );
