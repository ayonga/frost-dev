classdef ContinuousDomain
    % ContinuousDomain defines an admissible continuous domain (or phase)
    % in the hybrid system model. The admissibility conditions are
    % determined by the constraints defined on the domain.
    % 
    % Contraints are typically given as kinematic constraints, such as
    % holonomic constraints and unilateral constraints, of the rigid body
    % model.
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
    
    
    %% Protected properties
    properties (SetAccess=private, GetAccess=public)
        
        %% basic properties
        
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        name
        
        
        %% holonomic constraints
        
        % a cell array of holonomic constraints given as objects of
        % Kinematics classes
        %
        % @type cell
        hol_constr
        
        % a cell string of holonomic constraint names defined on the domain
        %
        % @type cellstr
        hol_constr_name
        
        % the number of holonomic constraints
        %
        % @type integer
        n_hol_constr
        
        % a structure of function names defined for the domain. Each field
        % of 'funcs' specifies the name of a function that used for a
        % certain computation of the domain.
        %
        % Required fields of funcs:
        %   hol_constr_func: a string of the function that computes the
        %   value of holonomic constraints @type char
        %   hol_constr_jac: a string of the function that computes the
        %   jacobian of holonomic constraints @type char
        %   hol_constr_jacdot: a string of the function that computes time derivatives of the
        %   jacobian matrix of holonomic constraints @type char
        %
        % @type struct
        funcs
        
       
        
        % Specific options for the domain
        %
        % @type struct
        options
        
        
        
    end
    
    %% Public methods
    methods
        
        function obj = ContinuousDomain(name)
            % the default calss constructor
            %
            % Parameters:
            % name: the name of the domain @type char
            %
            % Return values:
            % obj: the class object
            
            if nargin > 0
                if ischar(name)
                    obj.name = name;
                else
                    warning('The domain name must be a string.');
                end
            end
            
            
            obj.hol_constr = {};
            obj.hol_constr_name = {};
            obj.funcs = struct();
            obj.funcs.hol_constr_func = '';
            obj.funcs.hol_constr_jac = '';
            obj.funcs.hol_constr_jacdot = '';
        end
        
        
        function obj = addHolnomicConstraint(obj, constr_list)
            % Adds holonomic constraints for the domain
            %
            % Parameters:
            %  constr_list: a cell array of new holonomic constraints @type
            %  cell
            
            % validate holonomic constraints
            
            if any(cellfun(@(x) ~isa(x,'Kinematics'),constr_list))
                error('ContinuousDomain:invalidConstr', ...
                    'There exist non-Kinematics objects in the list.');
            end
            
            obj.hol_constr = horzcat(obj.hol_constr, constr_list);
            
            new_constr_name = cellfun(@(x) {x.name},constr_list,'UniformOutput',false);
            
            obj.hol_constr_name = horzcat(obj.hol_constr_name, new_constr_name);
        end
        
        function obj = removeHolonomicConstraint(obj, constr_list)
            % Removes holonomic constraints from the defined holonomic
            % constraints of the domain
            %
            % Parameters:
            %  constr_list: a cell array of holonomic constraints to be
            %  removed @type cell
            
            if any(cellfun(@(x) ~isa(x,'Kinematics'),constr_list))
                error('ContinuousDomain:invalidConstr', ...
                    'There exist non-Kinematics objects in the list.');
            end
            
            remove_constr_name = cellfun(@(x) {x.name},constr_list,'UniformOutput',false);
            
            indices_c = str_indices(remove_constr_name,obj.hol_constr_name,'UniformOutput',false);
            
            not_found_indidces = find(cellfun('isempty',indices_c), 1);
            
            if isempty(not_found_indidces)
                warning('the constraints do not exists.');
                for k = 1:length(not_found_indidces)
                    disp('%s, ',obj.hol_constr_name{not_found_indidces(k)});
                end
            end
            indices = [indices_c{:}];
            
            for i = indices
                obj.hol_constr{i} = {};
                obj.hol_constr_name{i} = {};
            end
            
            obj.hol_constr = horzcat(obj.hol_constr{:});
            
            obj.hol_constr_name = horzcat(obj.hol_constr_name{:});
        end
        
        function obj = compileFunction(obj)
            
            
        end
        
        
        
        
        function obj = setFunctionName(obj, props, values)
            % Set the name of functions for the domain.
            %
            % The usage is similar to set/get function of
            % matlab.mixin.SetGet class, except this function does not
            % support array objects. In addition, it has input argument
            % validations specific to the current class.
            %
            % Parameters:
            %  props: a string or cellstr of function name properties @type
            %  cellstr
            %  values: values of the properties @type cellstr
            %
            % See also: matlab.mixin.SetGet
            
            valid_props = fields(obj.funcs);
            
            if ischar(props)
                v_prop = validatestring(props,valid_props);
                if ischar(values)                    
                    obj.(v_prop) = values;
                elseif iscell(values)
                    obj.(v_prop) = values{1};
                else
                    error('The value must be a string or cell string.');
                end
            elseif iscell(props)
                for i = 1:length(props)
                    v_prop = validatestring(props,valid_props);
                    if ischar(values{i})
                        obj.(v_prop) = values{1};
                    else
                        error('The value must be a string or cell string.');
                    end
                end
            else
                error(['The props must be a string or cell strings that match one of these strings:\n',...
                    '%s,\t'],valid_props);
            end
            
        end
        
        
        
        
        
        
        
    end
        
    
end

