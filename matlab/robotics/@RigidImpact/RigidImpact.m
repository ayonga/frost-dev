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
    properties (Constant, Hidden)
        g = [0;0;9.81]
    end
    
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
        
        PostImpactModel
        
    end
    
    methods
        
        function obj = RigidImpact(name, model, event)
            % the class constructin method
            %
            % Parameters:
            % name: the name of the rigid impact dynamics @type char
            % model: the RigidLinks model object @type RigidLinks
            % event: the event name of the rigid impact @type char
            
          
            
            obj = obj@DiscreteDynamics(name, 'SecondOrder', event);
            
            validateattributes(model,{'RobotLinks'},{},...
                'RigidImpact','model',2);
            
            obj.Dimension = model.Dimension;
            
            
            bounds = model.getBounds();
            
                        
            obj.configureSystemStates(bounds.states);
            
            v = cell(1,obj.Dimension);
            vn = cell(1,obj.Dimension);
            f = cell(1,obj.Dimension);
            for i = 1:obj.Dimension
                v{i} = StateVariable(['v',num2str(i)],6);
                vn{i} = StateVariable(['vn',num2str(i)],6);
                f{i} = StateVariable(['f',num2str(i)],6,[],[]);
            end
            
            obj.addState(v{:},vn{:},f{:});
            
            
            
            obj.ImpactConstraints = model.HolonomicConstraints;
            
            constrs = fieldnames(obj.ImpactConstraints);
            for i=1:length(constrs)
                constr = obj.ImpactConstraints.(constrs{i});
                f = model.Inputs.(constr.f_name);
                obj.addInput(f);
            end
            
            obj.R = eye(obj.Dimension);
            obj.PostImpactModel = model;
            obj.calcDiscreteMap = @(obj, t, x)calcImpactMap(obj, t, x);
        end
        
        function set.R(obj, R)
            
            validateattributes(R,{'numeric'},...
                {'2d','size',[obj.Dimension,obj.Dimension],'integer'},...
                'RigidImpact','R');
            obj.R = R;
        end
        
        
        
        
    end
    
    
end

