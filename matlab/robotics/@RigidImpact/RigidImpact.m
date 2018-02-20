classdef RigidImpact < DiscreteDynamics
    % RigidImpact represents a rigid body impact map assuming that the
    % impact is plastic and occurs instantaneously. 
    %
   
    %
    % @author Ayonga Hereid @date 2017-04-26
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties 
        
        
        % The coordinate relabeling matrix
        %
        % @type matrix
        R
        
    end
    properties (SetAccess=protected)
        
        
        % The impact constraints (holonomic)
        %
        % @type HolonomicConstraint
        ImpactConstraints
        
        
        
    
    end
    
    properties (Access=public)
        
        % The mass matrix of the RigidLinks object
        %
        % @type SymFunction
        Mmat
        
        % The reset map constraint for the joint configuration
        %
        % @type SymFunction
        xMap
        
        
        % The reset map constraint for the joint velocity
        %
        % @type SymFunction
        dxMap
    end
    
    methods
        
        function obj = RigidImpact(name, model, event)
            % the class constructin method
            %
            % Parameters:
            % name: the name of the rigid impact dynamics @type char
            % model: the RigidLinks model object @type RigidLinks
            % event: the event name of the rigid impact @type char
            
            validateattributes(model,{'RobotLinks'},{},...
                'RigidImpact','model',2);
            
            if nargin > 2
                superargs = {'SecondOrder', name, event};
            else
                superargs = {'SecondOrder', name};
            end
            
            
            obj = obj@DiscreteDynamics(superargs{:});
            
            validateattributes(model,{'RobotLinks'},{},...
                'RigidImpact','model',2);
            
            obj.ImpactConstraints = struct();
            
            
           
            nx = model.numState;
            
            x = model.States.x;
            dx = model.States.dx;
            label = x.label;
            xn = SymVariable('xn',[nx,1],label);
            dxn = SymVariable('dxn',[nx,1],label);
            
            obj = addState(obj, x, xn, dx, dxn);
            
            obj.R = eye(nx);
            obj.Mmat = model.Mmat;
            
            obj.UserNlpConstraint = @obj.rigidImpactConstraint;
        end
        
        function obj = set.R(obj, R)
            
%             validateattributes(R,{'numeric'},...
%                 {'2d','size',[obj.numState,obj.numState],'integer'},...
%                 'RigidImpact','R');
            obj.R = R;
        end
        
        function obj  = configure(obj, load_path)
            % configure the reset map expression for the rigid impact
            % object
            %
            % Parameters:
            %  load_path: the path from which the symbolic experssion can
            %  be load @type char
            
            
            if nargin < 2, load_path = []; end;
            
            
            
            x = obj.States.x;
            xn = obj.States.xn;
            dx = obj.States.dx;
            dxn = obj.States.dxn;
            
                
            % the configuration only depends on the relabeling matrix
            if ~isempty(load_path)
                obj.xMap = SymFunction(['xDiscreteMap' obj.Name],[],{x,xn});
                obj.xMap = load(obj.xMap, load_path);
                
                obj.dxMap = SymFunction(['dxDiscreteMap' obj.Name],[],{dx,dxn});
                obj.dxMap = load(obj.dxMap, load_path);
            else
                obj.xMap = SymFunction(['xDiscreteMap' obj.Name],obj.R*x-xn,{x,xn});
                
                cstr_name = fieldnames(obj.ImpactConstraints);
                
                % the velocities determined by the impact constraints
                if isempty(cstr_name)
                    % by default, identity map
                    
                    obj.dxMap = SymFunction(['dxDiscreteMap' obj.Name],obj.R*dx-dxn,{dx,dxn});
                    
                else
                    %% impact constraints
                    cstr = obj.ImpactConstraints;
                    n_cstr = numel(cstr_name);
                    nx  = length(x);
                    % initialize the Jacobian matrix
                    Gvec = zeros(nx,1);
                    deltaF = cell(1, n_cstr);
                    input_name = cell(1,n_cstr);
                    for i=1:n_cstr
                        c_name = cstr_name{i};
                        input_name{i} = cstr.(c_name).InputName;
                        Gvec = Gvec + obj.Gvec.ConstraintWrench.(input_name{i});
                        deltaF{i} = obj.Inputs.ConstraintWrench.(input_name{i});
                    end
                    
                    % D(q) -> D(q^+)
                    M = subs(obj.Mmat, x, xn);
                    Gvec = subs(Gvec, x, xn);
                    % D(q^+)*(dq^+ - R*dq^-) = sum(J_i'(q^+)*deltaF_i)
                    delta_dq = M*(dxn - obj.R*dx) - Gvec;
                    obj.dxMap = SymFunction(['dxDiscreteMap' obj.Name],delta_dq,[{dx},{xn},{dxn},deltaF]);
                    
                    
                end
            end
        end
        
        function obj = addImpactConstraint(obj, constr, load_path)
            % Adds an impact constraint to the rigid impact map
            %
            %
            % Parameters:
            % constr: the expression of the constraints @type HolonomicConstraint
            
            
            % validate input argument
            validateattributes(constr, {'HolonomicConstraint'},...
                {},'RigidImpact', 'ImpactConstraint');
            
            n_constr = numel(constr);
            
            if nargin < 3
                load_path = [];
            end
            
            for i=1:n_constr
                c_obj = constr(i);
                c_name = c_obj.Name;
                
                if isfield(obj.ImpactConstraints, c_name)
                    error('The impact constraint (%s) has been already defined.\n',c_name);
                else
                    
                    % add virtual constraint
                    obj.ImpactConstraints.(c_name) = c_obj;
                    
                    % add constant parameters
                    % obj = addParam(obj, c_obj.ParamName, c_obj.Param);
                    Jh = c_obj.ConstrJac;
                    if isempty(load_path)
                        obj = addInput(obj, 'ConstraintWrench', c_obj.InputName, c_obj.Input, transpose(Jh));
                    else
                        obj = addInput(obj, 'ConstraintWrench', c_obj.InputName, c_obj.Input, transpose(Jh), 'LoadPath', load_path);
                    end
                end
                
            end
            
            obj  = configure(obj, load_path);
            
            
        end
        
        
        function obj = removeImpactConstraint(obj, name)
            % Remove impact (holonomic) constraints defined for the system
            %
            % Parameters:
            % name: the name of the constraint @type cellstr
            
            assert(ischar(name) || iscellstr(name), ...
                'The name must be a character vector or cellstr.');
            if ischar(name), name = cellstr(name); end
            
            
            for i=1:length(name)
                constr = name{i};
                
                if isfield(obj.ImpactConstraints, constr)
                    c_obj = obj.ImpactConstraints.(constr);
                    obj.ImpactConstraints = rmfield(obj.ImpactConstraints,constr);
                    % obj = removeParam(obj,c_obj.ParamName);
                    obj = removeInput(obj,'ConstraintWrench',c_obj.InputName);
                else
                    error('The impact constraint (%s) does not exist.\n',constr);
                end
            end
            
            obj  = configure(obj);
        end
        
        
    end
    
    methods
        nlp = rigidImpactConstraint(obj, nlp, src, tar, bounds, varargin);
        
        
        [tn, xn,lambda] = calcDiscreteMap(obj, t, x, varargin);
        
        obj = compile(obj, export_path, varargin);

        obj = saveExpression(obj, export_path, varargin);
    end
    
end

