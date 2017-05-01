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
    properties (SetAccess=protected)
        
        
        
        % A handle to a function called by a trajectory optimization NLP to
        % enforce system specific constraints. 
        %
        % @note The function handle should have the syntax:
        % userNlpConstraint(edge_nlp, src_nlp, tar_nlp, bounds, varargin)
        %
        % @type function_handle
        UserNlpConstraint
    end
    
    properties
        
        % The event name that triggers the discrete dynamics
        %
        % @type char
        EventName
        
        
    end
    
    
    
    methods
        
        function obj = DiscreteDynamics(type, name, event)
            % the constructor function for DiscreteDynamics class objects
            %
            % Parameters:
            % type: the type of the system @type char
            % name: the name of the system @type char
            % event: the event name associated with the discrete map 
            % @type char
            
            if nargin > 1
                superargs = {type, name};
            else
                superargs = {type};
            end
            
            obj = obj@DynamicalSystem(superargs{:});
            
            if nargin > 2
                obj.EventName = event;
            end
            
            obj.UserNlpConstraint = @obj.IdentityMapConstraint;
        end
        
        
        function obj = set.EventName(obj, event)
            
            if ischar(event)
                obj.EventName = event;
            elseif isa(event,'UnilateralConstraint')
                obj.EventName = event.Name;
            end
        end
        
        function obj = addState(obj, xplus, xminus, dxplus, dxminus)
            % overload the superclass 'addState' method with fixed state
            % fields
            % 
            % Parameters:            
            % x: the pre-impact state variables @type SymVariable
            % xplus: the post-impact state variables @type SymVariable
            % dx: the post-impact first order derivative of state variables @type SymVariable
            % dxplus: the post-impact first order derivative of state variables @type SymVariable
            
            
        
            if strcmp(obj.Type,'FirstOrder')
                obj = addState@DynamicalSystem(obj,'x',xplus);
                obj = addState@DynamicalSystem(obj,'xn',xminus);
            elseif strcmp(obj.Type, 'SecondOrder')
                obj = addState@DynamicalSystem(obj,'x',xplus, 'dx',dxplus);
                obj = addState@DynamicalSystem(obj,'xn',xminus, 'dxn',dxminus);
            else
                error('Please define the type of the system first.');
            end
        end
        
        
        
        
        
        
        
        nlp = IdentityMapConstraint(obj, nlp, src, tar, bounds, varargin);
    end
        
    
    
end

