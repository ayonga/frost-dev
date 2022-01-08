classdef (Abstract) DynamicalSystem < handle & matlab.mixin.Copyable
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
        
        
        % The type of the system (FirstOrder or SecondOrder)
        %
        % @type char
        Type char 
        
                               
        % An array of state variables of the system
        %
        %
        % Additional states can be added to the list, but will not be
        % integrated in simulation (will be collocated in optimization)
        % 
        % @type struct
        States struct = struct()
        
        
        % An array of state variables of the system
        %
        % 
        % @type struct
        Inputs struct = struct()
        
        % The parameters of the system
        %
        % @type struct
        Params struct = struct()
        
        % The time variable of the system
        %
        % @type SymVariable
        Time BoundedVariable 
        
        
    end
    
    properties
        
        
        % The unique name identification of the system
        %
        % @type char
        Name char
        
        % The dimension of the configuration space (i.e., degrees of
        % freedom)
        %
        % @type integer
        Dimension double 
        
        % A handle to a function called by a trajectory optimization NLP to
        % enforce system specific constraints. 
        %
        %
        % @type function_handle
        CustomNLPConstraint 
        
    end
    
    % methods defined in external files
    methods 
        
        % Add state variables
        obj = addState(obj, states);
        
        % Remove state variables
        obj = removeState(obj, state_names);
        
        % Add input variables
        obj = addInput(obj, inputs);
        
        % Remove input variables
        obj = removeInput(obj, input_names);
        
        % Add parameter variables
        obj = addParam(obj, params);
        
        % Remove parameter variables
        obj = removeParam(obj, param_names);
       
        % Obtain the limits of system variables
        bounds= getBounds(obj);
    end
    
    methods (Abstract)
        nlp = imposeNLPConstraint(obj, nlp, varargin);
    end
    
    methods
        function obj = DynamicalSystem(name, type)
            % The class construction function
            %
            % Parameters:
            % name: the name of the system @type char
            % type: the system time (Discrete or Continuous) @type char
            
            arguments
                name char {mustBeValidVariableName}
                type char {mustBeMember(type,{'FirstOrder','SecondOrder'})}  
            end
            
            obj.Name = name;
            obj.Type = type;       
            obj.Time = BoundedVariable('t',1,0,inf);
            setAlias(obj.Time, 'Time');
        end
        
        function set.Name(obj, name)
           
            arguments
                obj
                name {mustBeValidVariableName}
            end
            obj.Name = name;
            
        end
        
        function set.Dimension(obj, dim)
            
            arguments
                obj
                dim (1,1) {mustBeInteger,mustBePositive}
            end
                       
            obj.Dimension  = dim;
            
        end
        
        function set.CustomNLPConstraint(obj, func)
            
            arguments
                obj DynamicalSystem
                func (1,1) function_handle
            end
            
            obj.CustomNLPConstraint = func;
        end
        
        
        function ret= isParam(obj, name)
            % 
            %
            % Parameters:
            %  name: the name string of the variable @type char
            
            if isfield(obj.Params, name)
                ret = true;
            else
                ret = false;
            end
            
        end
        
        function var_group= validateVarName(obj, name)
            % validateVarName(obj, name_str) validates the group and
            % category of the variables specified by the argument 'name'
            %
            % validateVarName:
            %  name: the name of the variable @type char
            
            arguments
                obj DynamicalSystem
                name char
            end
            
            if isfield(obj.States, name) % check if it is a state variables
                var_group = 'States';
            elseif isfield(obj.Inputs, name) % check if it is a control input variables
                var_group = 'Inputs';
            elseif isfield(obj.Params, name) % check if it is a parameter variables
                var_group = 'Params'; 
            elseif strcmp(name, 't')
                var_group = 'Time';
            else
                var_group = [];
            end
            
        end
        
        
        
    end
    
    methods 
       
        function value = getValue(obj, vars)
            % returns the variables (vars) value that are stored during
            % computing the dynamics
            arguments
                obj
            end
            
            arguments (Repeating)
                vars char
            end
            
            if ~iscell(vars), vars = {vars}; end
            
            var_group = cellfun(@(x)obj.validateVarName(x), vars, 'UniformOutput', false);
            n_vars = numel(vars);
            value = cell(1,n_vars);
            
            for i=1:n_vars
                tmp = var_group{i};
                switch tmp
                    case 'States'
                        value{i} = obj.states_.(vars{i});
                    case 'Inputs'
                        value{i} = obj.inputs_.(vars{i});
                    case 'Params'
                        value{i} = obj.params_.(vars{i});
                    case 'Time'
                        value{i} = obj.t_;
                    otherwise
                        error('(%s) is an undefined variable of the system (%s).',vars{i}.Name, obj.Name);
                end
            end
            
        end
        
        
    
        
    end
    
    % The values for the system variables
    properties(SetAccess=protected,Hidden)
        
        % The time 
        %
        % @type double
        t_
        
        % The states
        %
        % @type struct
        states_ = struct()
        
        % The inputs
        %
        % @type struct
        inputs_ = struct()
        
        % The parameters
        %
        % @type struct
        params_ = struct()
        
    end
end

