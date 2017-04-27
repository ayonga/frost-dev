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
        
        % The event function of the discrete event dynamical system
        %
        % @type UnilateralConstraint
        EventFunc
        
        % The stamp data logger
        % 
        % @type struct
        Stamp
    end
    
    methods
        
        function obj = DiscreteDynamics(name)
            % the constructor function for DiscreteDynamics class objects
            %
            % Parameters:
            % name: the name of the object @type char
            
            obj = obj@DynamicalSystem(name);
            
        end
        
        function obj = addState(obj, xplus, xminus)
            % overload the superclass 'addInput' method with fixed state
            % fields
            
            obj = addState@DynamicalSystem(obj,'xplus',xplus,'xminus',xminus);
        
        end
        
        function obj = setEventFunc(obj, constr)
            % Set the event function G(x,f) of the system
            %
            % Parameters:
            %  constr:  the event function @type UnilateralConstraint
            
            validateattributes(constr,{'UnilateralConstraint'},...
                {'scalar'},'DiscreteDynamics','EventFunc');
            
            assert(constr.Dimension==1,...
                'The event function must be a scalar unilateral constraint object.');
            
            obj.EventFunc = constr;
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
            
            export(obj.EventFunc,export_path,varargin{:});
            
        end
        
        function obj = preProcess(obj, cur_node, params)
            % do nothing
        end
    end
        
    methods (Abstract)
        % calculates the discrete map of the dynamical system that maps
        % xminus from xplus. Subclasses must implement this method by its
        % own.
        xplus = calcDiscreteMap(obj, t, xminus, cur_node);
        
        % calculates the event function
        value = calcEvent(obj, t, x, cur_node);
    end
    
end

