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
        
        
        % The unique name identification of the system
        %
        % @type char
        Name
        
    end
    
    
    properties 
        
        % Returns the external input defined on the dynamical system.
        %
        % @type function_handle
        ExternalInputFun
    end
    
    % regular properties
    properties (SetAccess=protected)
        % The highest order of the state derivatives of the system
        %
        % @note The system could be either a 'FirstOrder' system or a
        % 'SecondOrder' system.
        %
        % @type char
        Type
        
        
        
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
        % We categorized input signals into three different groups: 
        % Control: the control input
        % ConstraintWrench: the constrained wrench from any bilateral
        % (holonomic or nonholonomic) constraints
        % External: other external inputs, such as disturbance, etc.
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
    
    
    
    % methods defined in external files
    methods 
        
        % Add state variables
        obj = addState(obj, varargin);
        
        % Add input variables
        obj = addInput(obj, category, name, var, gf, varargin);
        
        % Remove input variables
        obj = removeInput(obj, category, name);
        
        % Add parameter variables
        obj = addParam(obj, varargin);
        
        % Remove parameter variables
        obj = removeParam(obj, param_name);
        
        % set values for parameter variables
        obj = setParamValue(obj, varargin);
        
        % compile symbolic expression
        obj = compile(obj, export_path, varargin);
        
        % load symbolix expressions of system dynamics
        obj = loadDynamics(obj, export_path, varargin);
        
        % export symbolic expression to MX binary
        obj = saveExpression(obj, export_path, varargin);
    end
    
    
    methods
        function obj = DynamicalSystem(type, name)
            % The class construction function
            %
            % Parameters:
            % type: the type of the system @type char
            % name: the name of the system @type char
            
            
            
            obj.Type = obj.validateSystemType(type);
            if nargin > 1
                assert(isvarname(name),...
                    'The name of the system must be a valid variable name vector.');
                obj.Name = name;
            end
            
            % initialize the properties
            obj.States = struct();
            obj.Inputs = struct();
            obj.Inputs.Control = struct();
            obj.Inputs.ConstraintWrench = struct();
            obj.Inputs.External = struct();
            
            obj.inputs_.Control = struct();
            obj.inputs_.ConstraintWrench = struct();
            obj.inputs_.External = struct();
            
            obj.Params = struct();
            
            obj.Gmap = struct();
            obj.Gmap.Control = struct();
            obj.Gmap.ConstraintWrench = struct();
            obj.Gmap.External = struct();
            
            obj.Gvec = struct();
            obj.Gvec.Control = struct();
            obj.Gvec.ConstraintWrench = struct();
            obj.Gvec.External = struct();
            
            obj.ExternalInputFun = str2func('nop');
        end
        
        function obj = setName(obj, name)
            % set the name of the dynamical system
            
            assert(isvarname(name),...
                'The name of the system must be a valid variable name vector.');
            obj.Name = name;
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
            % Validate the group and category of the variables specified by
            % the input 'name'
            %
            % Parameters:
            %  name: the name string of the variable @type char
            
            if isfield(obj.States, name) % check if it is a state variables
                var_group = {'States',''};
            elseif isfield(obj.Inputs.Control, name) % check if it is a control input variables
                var_group = {'Inputs','Control'};
            elseif isfield(obj.Inputs.ConstraintWrench, name) % check if it is a control input variables
                var_group = {'Inputs','ConstraintWrench'};
            elseif isfield(obj.Inputs.External, name) % check if it is a control input variables
                var_group = {'Inputs','External'};
            elseif isfield(obj.Params, name) % check if it is a parameter variables
                var_group = {'Params',''}; 
            else
                var_group = {'',''};
            end
            
        end
        
        
        function obj = setType(obj, type)
            % Sets the type of the dynamical system
            %
            % Parameters: 
            % type: the system type @type char
            
            obj.Type = obj.validateSystemType(type);
        end
        
        
        %         function new = clone(obj, new)
        %             % Copies the value of properties of the object to a new object
        %
        %             prop_list = properties(obj);
        %
        %             for i=1:numel(prop_list)
        %                 prop = prop_list{i};
        %
        %                 if isprop(new, prop) && ~strcmp(prop,'Name')
        %                     new.(prop) = obj.(prop);
        %                 end
        %             end
        %
        %         end
    end
    
    methods (Access=protected)
       
        function value = getValue(obj, vars)
            % returns the variables (vars) value that are stored during
            % computing the dynamics
            
            if ~iscell(vars), vars = {vars}; end
            
            var_group = cellfun(@(x)obj.validateVarName(x), vars, 'UniformOutput', false);
            n_vars = numel(vars);
            value = cell(1,n_vars);
            
            for i=1:n_vars
                tmp = var_group{i};
                switch tmp{1}
                    case 'States'
                        value{i} = obj.states_.(vars{i});
                    case 'Inputs'
                        value{i} = obj.inputs_.(tmp{2}).(vars{i});
                    case 'Params'
                        value{i} = obj.params_.(vars{i});
                end
            end
        end
        
        function v_type = validateSystemType(~, type)
            % validate if it is valid system type
            
            v_type = validatestring(type,{'FirstOrder','SecondOrder'});
        end
    
        
    end
    
    % The values for the system variables
    properties(Access=protected,Hidden)
        
        % The time 
        %
        % @type double
        t_
        
        % The states
        %
        % @type struct
        states_
        
        % The inputs
        %
        % @type struct
        inputs_
        
        % The parameters
        %
        % @type struct
        params_
        
        
        % The name of the Gmap functions
        %
        % @type struct
        GmapName_
        
        % The name of the Gvec functions
        %
        % @type struct
        GvecName_
    end
end

