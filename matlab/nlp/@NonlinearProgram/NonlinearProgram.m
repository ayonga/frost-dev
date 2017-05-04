classdef NonlinearProgram < handle
    % NonlinearProgram defines an abstract class for general nonlinear
    % programing problems
    % 
    %
    % @author Ayonga Hereid @date 2016-10-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        % The name of the problem
        %
        % @type char
        Name
        
        % The class option
        %
        % Required fields of options:
        %  DerivativeLevel: the user-defined derivative order (0, 1 or 2)
        %  to be used by a NLP solver. @type integer @default 1
        %  EqualityConstraintBoundary：a relaxation factor number for equality
        %  constraints. @type double
        % 
        % @type struct
        Options 
        
        
        % An array contains all information regarding NLP
        % optimization variables
        %
        % @type NlpVariable
        VariableArray
        
                
        % An array data stores objective functions
        %
        % @type NlpFunction
        CostArray
        
        % A cell array data stores all constraints functions
        %
        % @type NlpFunction
        ConstrArray
        
        
        
    end
    
    properties 
        % The solution of the NLP problem
        Sol
    end
    
    
    %% Public methods
    methods
        
        function obj = NonlinearProgram(name)
            % The default class constructor function
            %
            % Parameters: 
            %  name: the name of the problem
            
            if nargin > 0
                validateattributes(name, {'char'},...
                    {'scalartext'},'NonlinearProgram','name');
                obj.Name = name;
            end
            % default options
            obj.Options = struct('DerivativeLevel', 1, ...
                'EqualityConstraintBoundary', 0);
            
            
            
            
        end
        
    end
    
    %% Function definitions
    methods
        
        [obj] = regVariable(obj, vars);
        
        [obj] = update(obj);
        
        [obj] = regObjective(obj, funcs);
        
        [obj] = regConstraint(obj, funcs);
        
        [nVar, lowerbound, upperbound] = getVarInfo(obj);
        
        [x0] = getInitialGuess(obj, method);
        
        obj = setOption(obj, varargin);
       
        compileConstraint(obj, export_path, varargin);
        
        compileObjective(obj, export_path, varargin);
    end
        
    
end

