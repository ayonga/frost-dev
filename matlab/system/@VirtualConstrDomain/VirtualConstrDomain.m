classdef VirtualConstrDomain < Domain
    % Defines a subclass of continuous domain with virtual constraints.
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
    
    properties
        
        % The parameterized time variable (phase variable)
        %
        % @type 
        Tau
        
        % The position-modulating outputs of the domain
        %
        % The position-modulating outputs are (vector) relative degree two
        % by definition.
        % 
        % @type 
        PositionOutput
        
        % The velocity-modulating output of the domain
        %
        % The velocity-modulating outputs are relative degree one
        % by definition.
        % 
        % @type
        VelocityOutput
    end % properties
    
    
    methods
        function obj = VirtualConstrDomain(name, varargin)
            % The class constructor function
            
            
            obj = obj@Domain(name,varargin);
            
        end
        
        
        function obj = setPhaseVariable(obj, var, par)
            % Sets the parameterized time variable (phase variable)
            %
            % Parameters:
            % kin: the kinematic function for the phase variable 
            % @type Kinemtics
            
            obj.Tau = var;
        end
         
        function obj = addVelocityOutput(obj, act, des)
            % Adds a velocity-modulating output of the domain
            %
            % Parameters:
            % kin: the kinematic function for the position-modulating
            % output @type Kinemtics
            
            obj.PositionOutput = struct;
            obj.PositionOutput.actual
            obj.PositionOutput.desired
        end
        
        function obj = addPositionOutput(obj, act, des)
            % Adds position-modulating outputs of the domain
            %
            % Parameters:
            % kin: the kinematic function for the velocity-modulating
            % output @type Kinemtics
            
            
        end
        
    end % methods
end % classdef
