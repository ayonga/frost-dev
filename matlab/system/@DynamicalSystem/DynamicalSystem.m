 classdef (Abstract) DynamicalSystem < handle
    % A superclass for continuous/discrete dynamic systems
    %    
    %
    % @author ayonga @date 2017-02-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess=protected)
        % The unique name identification of the system
        %
        % @type char
        Name
        
        % A structure that contains the symbolic representation of state
        % variables
        %
        % Required fields of States:
        %  x: the state variables x(t) @type SymVariable
        %  dx: the first order derivatives of X, i.e. xdot(t)
        %  @type SymVariable
        %
        % Optional fields of States:
        %  ddx: the second order derivatives of X , i.e. xddot(t) 
        %  @type SymVariable
        %
        % @type struct
        States
        
        % The total number of system states
        %
        % @type double
        numState
        
        % A structure that contains the symbolic representation of input
        % variables
        %
        % @type struct
        Inputs
        
        % The parameters of the system
        %
        % @type struct
        Params
        
        
        % The struct of input vector fields Gvec(x,u) SymFunction
        %
        % @type struct
        Gvec
        
        % The struct of input map Gmap(x) SymFunction
        %
        % @type struct
        Gmap
        
    end
    
    
    methods (Abstract)
        % calculate the dynamic equation/map
        varargout = calcDynamics(obj, varargin);
        % compile symbolic expression related to the systems
        obj = compile(obj, export_path, varargin);
        
        % a method called by a trajectory optimization NLP to enforce
        % system specific constraints. All subclasses should implement
        % their own version of this method and must call the superclass
        % method first in your implementation.
        nlp = addSystemConstraint(obj, nlp);
    end
    
    % methods defined in external files
    methods 
        
        % Add state variables
        obj = addState(obj, varargin);
        
        % Add input variables
        obj = addInput(obj, name, var, gf, varargin);
        
        % Remove input variables
        obj = removeInput(obj, input_name);
        
        % Add parameter variables
        obj = addParam(obj, varargin);
        
        % Remove parameter variables
        obj = removeParam(obj, param_name);
        
        
    end
    
    methods
        function obj = DynamicalSystem(name)
            % The class construction function
            %
            % Parameters:
            % name: the name of the system @type char
            
            assert(isvarname(name),...
                'The name of the system must be a valid variable name vector.');
            obj.Name = name;
            
            
            obj.States = struct();
            obj.Inputs = struct();
            obj.Params = struct();
            
            obj.Gmap = struct();
            obj.Gvec = struct();
            
        end
        
        
        
        
    end
    
    
    
    methods
        function var_group = validateVarName(obj, name)
            % Adds unilateral (inequality) constraints on the dynamical system
            % states and inputs
            %
            % Parameters:
            %  name: the name string of the variable @type char
            
            if isfield(obj.States, name) % check if it is a state variables
                var_group = 'States';
            elseif isfield(obj.Inputs, name) % check if it is a input variables
                var_group = 'Inputs';
            elseif isfield(obj.Params, name) % check if it is a parameter variables
                var_group = 'Params';
            else
                error('The variable (%s) does not belong to any of the variable groups.', name);
            end
            
        end
    end
    
    
end

