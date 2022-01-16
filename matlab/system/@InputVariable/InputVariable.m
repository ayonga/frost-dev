classdef InputVariable < BoundedVariable
    % InputVariable: a class to describe dynamical system inputs.
    %
    % @author ayonga @date 2021-12-18
    %
    % Copyright (c) 2021, Cyberbotics Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        % The function handle that compute the projected inputs to the
        % system. The callback function should have the following syntax:
        % 
        % function [f] = myCallBackFuncs(inputVar, model, t, q, dq, logger)
        %
        %
        % @type function_handle
        CallbackFunction 
        
        
        % The function handle that impose custom constraints in TO
        %
        % @type function_handle
        CustomNLPConstraint
        
        % Parameters that may be used to determine the system inputs
        %
        % @type ParamVariable
        Params 
    end
    
    properties (SetAccess=protected, GetAccess=public)
        
                
        % The type of the input variables 
        %
        % @type string
        Category
        
        
        
        % A function that maps the input to the system dynamics
        %
        % @type SymExpression
        Gmap 
    end
    
    methods
        function obj = InputVariable(name, dim, lb, ub, cat)
           % InputVariable construct a class object
           %
           % Example:
           % % control input, default boundary values (-inf,inf)
           % u1 = InputVariable('u',5) 
           %
           % % assign external function to compute the projected input
           % u = InputVariable('u',5, 'CallbackFunction', @func)  
           
           
           arguments
               name char = ''
               dim {mustBeInteger,mustBePositive,mustBeScalarOrEmpty} = []
               lb  double = []
               ub  double = []
               cat char {mustBeMember(cat,{'','Control','ConstraintWrench','External', 'JointWrench'})} = ''
           end
           %                opts.Alias char = ''
           %                opts.Labels (:,:) cell = {}
           %                opts.CallbackFunction function_handle
           %                opts.Params ParamVariable = []
           %                opts.Gmap SymExpression = []
           %                opts.Category char = ''
           %            end
           
           obj = obj@BoundedVariable(name, dim, lb, ub);
           
           
           obj.Category = cat;
        end
        
        function setCategory(obj, cat)
            arguments
                obj
                cat {mustBeMember(cat,{'','Control','ConstraintWrench','External', 'JointWrench', 'ContactWrench'})}
            end
            obj.Category = cat;            
        end
       
        function set.CallbackFunction(obj, func)              
            assert(isa(func,'function_handle'),'The callback function must be a function handle');
            assert(nargin(func) == 5, 'The callback function must have exactly five (input, model, t, x, logger) inputs.');
            assert(nargout(func) >= 1, 'The callback function must have at least one (f) output');
            obj.CallbackFunction = func;
        end       
        
        function set.CustomNLPConstraint(obj, func)              
            assert(isa(func,'function_handle'),'The callback function must be a function handle');
            assert(nargin(func) >= 3, 'The callback function must have at least three (input, nlp, bounds) inputs.');
            %             assert(nargout(func) >= 1, 'The callback function must have at least one (f) output');
            obj.CustomNLPConstraint = func;
        end  
        
        
    end
    
    methods
        function setGmap(obj, gmap, model)
            arguments
                obj
                gmap SymExpression
                model DynamicalSystem
            end
            [nr,nc] = dimension(gmap);
            err_msg = sprintf('The size of the gmap should be (%d x %d).',model.Dimension,obj.Dimension);
            assert(nr==model.Dimension && nc==obj.Dimension(1),err_msg);
            
            obj.Gmap = SymFunction(['gmap_',obj.Name],gmap,{model.States.x});
        end
        
        function export(obj,export_path,varargin)
            
            export(obj.Gmap,export_path, varargin{:});
        end
    end
    
end

