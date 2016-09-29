classdef HybridDynamicalSystem
    % HybridDynamicalSystem defines a hybrid dynamical system that has both
    % continuous and discrete dynamics, such as bipedal locomotion.
    % 
    % This class provides basic elements and functionalities of a hybrid
    % dynamicsl system. The mathematical definition of the hybrid system is
    % given as
    % \f{eqnarray*}{
    % \mathscr{HC} = \{\Gamma, \mathcal{D}, U, S, \Delta, FG\}
    % \f}
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
        % The directed graph describes the structure of hybrid system model
        %
        % @type DirectedGraph       
        gamma
        
        % The continuous domain 
        %
        % @todo The current implementation is migrated from the old
        % 'domain' class, in which all elements (including continuous and
        % associated discrete events) are included in one class object.
        % Next step, separate them into multiple different class
        % definition.
        % 
        % @type HybridDomain
        domains
        
                
        % The model configuration of the rigid body system
        %
        % @type RigidBodyModel
        model
    end
    
    %% Public methods
    methods (Access = public)
        function obj = HybridDynamicalSystem(varargin)
            % the default calss constructor
            %
            % Parameters:
            % varargin: Optional arguments.
            %  
            %
            % Return values:
            % obj: the class object
            
            
        end
        
        
            
        
    end
        
    %% Protected methods
    methods (Access=protected)
    end
    
    %% Private methods
    methods (Access=private)
    end
    
end

