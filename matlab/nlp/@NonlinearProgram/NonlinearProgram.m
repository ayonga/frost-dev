classdef NonlinearProgram
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
        
        % The name identification
        %
        % @type char
        name
        
        % The class option
        %
        % Required fileds of options:
        %  withHessian: indicates whether the user-defined Hessian function
        %  is provided. @type logical @default false
        % 
        % @type struct
        options 
        
        
        % The structure array contains all information regarding NLP
        % optimization variables
        %
        % @type NlpVariable
        varArray
        
        % A data structure that stores the indexing of optimization
        % variables
        %
        % @type struct
        varIndex
        
        % A cell data stores registered objective functions
        %
        % @type cell
        costArray
        
        % A cell data stores registered constraints functions
        %
        % @type cell
        constrArray
        
        
        
        
        
    end
    
    properties (Access = protected)
        
        % The initial guess of the optimization variables
        %
        % @type colvec
        z0
       
        
    end
    
    %% Public methods
    methods
        
        function obj = NonlinearProgram(name, varargin)
            % The default class constructor function
            %
            
            p = inputParser;
            p.addRequired('name',@ischar);
            p.addParameter('withHessian',false,@islogical);
            
            
            p.parse(name, varargin{:});
            
            obj.name = p.Results.name;
            
            obj.options = struct();
            obj.options.withHessian = p.Results.withHessian;
            
            
            
            % initialize the type of the variables
            obj.varIndex = struct();
            obj.costArray  = cell(0);
            obj.constrArray = cell(0);
            
            
        end
        
    end
    
    %% Function definitions
    methods
        
        [obj] = addVariable(obj, name, dimension, varargin);
        
        [obj] = genVarIndices(obj);
        
        [obj] = addCost(obj, name, deps, extra);
        
        [obj] = addConstraint(obj, name, deps, dimension, cl, cu, extra);
        
        [nVar, lowerbound, upperbound] = getVarInfo(obj);
        
        [z0] = getStartingPoint(obj, varargin);
        
        [obj] = setInitialGuess(obj, z0);
        
        
        
    end
        
    
end

