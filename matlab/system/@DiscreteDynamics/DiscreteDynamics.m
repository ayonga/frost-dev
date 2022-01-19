classdef DiscreteDynamics < DynamicalSystem
    % Discrete event dynamic system governed by discrete transition map and
    % triggered by discrete events.
    %    
    %
    % @author ayonga @date 2017-04-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    % callback function handle properties to implement object specific
    % funtionalities outside of the class without making a new subclass
    properties
        
        % The event name that triggers the discrete dynamics
        %
        % @type EventFunction
        Event
        
    
        % function to compute the system dynamics
        %
        % @type function_handle
        calcDiscreteMap
    
    end
    
    methods
        
        function obj = DiscreteDynamics(name, type, event)
            % the constructor function for DiscreteDynamics class objects
            %
            % Parameters:
            % name: the name of the system @type char
            % event: the event name associated with the discrete map 
            % @type char
            
            arguments
                name char {mustBeValidVariableName}
                type char {mustBeMember(type,{'FirstOrder','SecondOrder'})} 
                event = []
            end
            
            obj = obj@DynamicalSystem(name, type);
            if ~isempty(event)
                setEvent(obj, event);
            end
            obj.calcDiscreteMap = @(obj, t, x)calcIdentityMap(obj, t, x);
        end
        
        
        function obj = setEvent(obj, event)
            
            arguments
                obj 
                event EventFunction
            end
            obj.Event = event;
            
        end
        
        function obj = configureSystemStates(obj, bounds)
            
            if isempty(obj.Dimension) || obj.Dimension <= 0
                error('Failed to configure system states. The system dimension is either undefined or non-positive.');
            end
            dim = obj.Dimension;
            
            if nargin < 2
                bounds = struct();
            end

            switch obj.Type
                case 'FirstOrder'
                    if isfield(bounds,'x')
                        lb = bounds.x.lb;
                        ub = bounds.x.ub;
                    else
                        lb = [];
                        ub = [];
                    end
                    x = StateVariable('x', dim, lb, ub);
                    setAlias(x,'Pre-Impact States');
                    xn = StateVariable('xn', dim, lb, ub);
                    setAlias(xn,'Post-Impact States');
                    
                    
                    
                    
                    obj.addState(x,xn);
                    
                case 'SecondOrder'
                    
                    if isfield(bounds,'x')
                        lb = bounds.x.lb;
                        ub = bounds.x.ub;
                    else
                        lb = [];
                        ub = [];
                    end
                    x = StateVariable('x', dim, lb, ub);
                    setAlias(x, 'Pre-Impact Position');
                    xn = StateVariable('xn', dim, lb, ub);
                    setAlias(xn, 'Post-Impact Position');
                    
                    if isfield(bounds,'dx')
                        lb = bounds.dx.lb;
                        ub = bounds.dx.ub;
                    else
                        lb = [];
                        ub = [];
                    end
                    dx = StateVariable('dx', dim, lb, ub);
                    setAlias(dx, 'Pre-Impact Velocity');
                    dxn = StateVariable('dxn', dim, lb, ub);
                    setAlias(dxn, 'Post-Impact Velocity');
                    
                    
                    
                    obj.addState(x,xn,dx,dxn);
                otherwise
                    error('Failed to configure system states. The system type is either undefined or incorrect.');
            end
            
        end
        
        function set.calcDiscreteMap(obj, func)
            assert(isa(func,'function_handle'),'The callback function must be a function handle');
            assert(nargin(func) >= 3, 'The callback function must have at least two (model, t, states) inputs.');
            %             assert(nargout(func) >= 1, 'The callback function must have at least one (tn, states_n) output');
            obj.calcDiscreteMap = func;
        end
    end
    
    
    % methods defined in separate files
    methods
        [tn, xn] = calcIdentityMap(obj, t, x);        
        
        obj = compile(obj, export_path, varargin);
        
        obj = saveExpression(obj, export_path, varargin);
        
        nlp = imposeNLPConstraint(obj, nlp, varargin);
    end
        
    
    
end

