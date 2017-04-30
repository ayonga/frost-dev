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
    
    
    properties
        
        % The event name that triggers the discrete dynamics
        %
        % @type char
        EventName
        
        
    end
    
    
    
    methods
        
        function obj = DiscreteDynamics(name, type, event)
            % the constructor function for DiscreteDynamics class objects
            %
            % Parameters:
            % name: the name of the object @type char
            % event: the event name associated with the discrete map 
            % @type char
            
            obj = obj@DynamicalSystem(name,type);
            
            if nargin > 2
                obj.EventName = event;
            end
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
            % xplus: the post-impact state variables @type SymVariable
            % xminus: the pre-impact state variables @type SymVariable
            % dxplus: the post-impact first order derivative of state variables @type SymVariable
            % dxminus: the post-impact first order derivative of state variables @type SymVariable
            
        
            if strcmp(obj.Type,'FirstOrder')
                obj = addState@DynamicalSystem(obj,'xplus',xplus);
                obj = addState@DynamicalSystem(obj,'xminus',xminus);
            elseif strcmp(obj.Type, 'SecondOrder')
                obj = addState@DynamicalSystem(obj,'xplus',xplus, 'dxplus',dxplus);
                obj = addState@DynamicalSystem(obj,'xminus',xminus, 'dxminus',dxminus);
            else
                error('Please define the type of the system first.');
            end
        end
        
        
        
        % compile symbolic expression related to the systems
        function obj = compile(obj, export_path, varargin)
            % export the symbolic expressions of the system dynamics matrices and
            % vectors and compile as MEX files.
            %
            % Parameters:
            %  export_path: the path to export the file @type char
            %  varargin: variable input parameters @type varargin
            %   Vars: a list of symbolic variables @type SymVariable
            %   File: the (full) file name of exported file @type char
            %   ForceExport: force the export @type logical
            %   BuildMex: flag whether to MEX the exported file @type logical
            %   Namespace: the namespace of the function @type char
            
        end
        
        
        
        
    end
        
    
    
end

