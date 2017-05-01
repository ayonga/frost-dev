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
    
    
    properties (SetAccess=protected)
        
        
        % The impact constraints (holonomic)
        %
        % @type HolonomicConstraint
        ImpactConstraints
        
        
        % The coordinate relabeling matrix
        %
        % @type matrix
        R
    
    end
    
    properties (Access=private)
        
        % The mass matrix of the RigidLinks object
        %
        % @type SymFunction
        Mmat
    end
    
    methods
        
        function obj = RigidImpact(model, event)
            % the class constructin method
            %
            % Parameters:
            % name: the name of the rigid impact dynamics @type char
            % model: the RigidLinks model object @type RigidLinks
            % event: the event name of the rigid impact @type char
            
            validateattributes(model,{'RigidLinks'},{},...
                'RigidImpact','model',1);
            
            if nargin > 1
                superargs = {'SecondOrder', model.Name, event};
            else
                superargs = {'SecondOrder', model.Name};
            end
            
            
            obj = obj@DiscreteDynamics(superargs{:});
            
            obj.ImpactConstraints = struct();
            
            
            label = model.States.x.label;
            nx = model.numState;
            
            x = model.Statex.x;
            dx = model.State.dx;
            xn = SymVariable('xn',[nx,1],label);
            dxn = SymVariable('dxn',[nx,1],label);
            
            obj = addState(obj, x, xn, dx, dxn);
            
            obj.R = eye(nx);
            obj.Mmat = model.Mmat;
            
            obj.UserNlpConstraint = @obj.rigidImpactConstraint;
        end
        
        function obj = set.R(obj, R)
            
            validateattributes(R,{'numeric'},...
                {'2d','size',[obj.numState,obj.numState],'integer'},...
                'RigidImpact','R');
            obj.R = R;
        end
        
        function obj = addImpactConstraint(obj, constr)
            % Adds an impact constraint to the rigid impact map
            %
            %
            % Parameters:
            % constr: the expression of the constraints @type HolonomicConstraint
            
            
            % validate input argument
            validateattributes(constr, {'HolonomicConstraint'},...
                {},'RigidImpact', 'ImpactConstr');
            
            n_constr = numel(constr);
            
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
                    obj = addInput(obj, 'ConstraintWrench', c_obj.InputName, c_obj.Input, transpose(Jh));
                end
                
            end
            
            
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
        end
        
        
    end
    
    methods
        nlp = rigidImpactConstraint(obj, nlp, src, tar, bounds, varargin);
    end
    
end

