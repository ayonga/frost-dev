classdef AnimatorPointOfView < uint8
    % The list of animator point of view
    % 
    % @author omar @date 2017-06-01
    % 
    % Copyright (c) 2017, UMICH Biped Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/BSD-3-Clause

    enumeration
        North (0)
        South (1)
        East (2)
        West (3)
        Front (5)
        Back (6)
        Right (7)
        Left (8)
        TopSouthEast (9)
        TopFrontLeft (10)
        Free (256)
    end
end
