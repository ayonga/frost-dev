classdef BipedModel < RigidBodyModel
    % BipedModel defines a bipedal robot model inherited from the general
    % rigid body model calss.
    % 
    % This class provides additional functionalities that are specific to
    % bipel robot, such as handling symmetric joints (left/right legs,
    % left/right arms).
    %
    % @author Ayonga Hereid @date 2016-09-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    %% Public properties
    properties (Access = public)
    end
    
    %% Constant properties
    properties (Constant)
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
    end
    
    %% Public methods
    methods (Access = public)
    end
        
    %% Protected methods
    properties (SetAccess=protected, GetAccess=public)
    end
    
    %% Private methods
    properties (Access=private)
    end
    
end

