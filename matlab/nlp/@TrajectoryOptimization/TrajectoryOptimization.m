classdef TrajectoryOptimization < NonlinearProgram
    % TrajectoryOptimization defines a particular type of nonlinear
    % programing problem --- trajectory optimization problem.
    % 
    %
    % @author Ayonga Hereid @date 2016-10-26
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
    
    %% Protected properties
    properties (Access = protected)
        
        
    end
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
        
    end
    
    %% Public methods
    methods (Access = public)
        
        function obj = TrajectoryOptimization(name, varargin)
            % The constructor function
            
            obj = obj@NonlinearProgram(name, varargin{:});
        end
        
        
        
    end
    
end

