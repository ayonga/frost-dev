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
        
        % The structure array contains all information regarding NLP
        % optimization variables
        %
        % @type NlpVar
        optVars
        
        % A data structure that stores the indexing of optimization
        % variables
        %
        % @type struct
        optVarIndices
        
        % Contains the information of registered cost functions in the form
        % of structure array
        %
        % @type NlpCost
        costArray
        
        % Contains the information of registered constraints in the form of
        % structure array
        %
        % @type NlpConstr
        constrArray
        
        
        
        
        % The class option
        %
        % Required fileds of options:
        %  withHessian: indicates whether the user-defined Hessian function
        %  is provided. @type logical @default false
        % 
        % @type struct
        options 
    end
    
    properties (Access = protected)
        
        % The initial guess of the decision variables
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
            
        end
        
    end
    
    %% Function definitions
    methods
        
        [obj] = addVariable(obj, name, dimension, varargin);
        
        [obj] = genVarIndices(obj);
        
        [obj] = addCost(obj, name, deps, extra);
        
        [obj] = addConstraint(obj, name, deps, dimension, cl, cu, extra);
        
        [dimOptVar, lb, ub] = getVarInfos(obj);
        
        [obj] = genCostIndices(obj);
        
        [costArray, costInfos] = getCostInfos(obj);
        
        [obj] = genConstrIndices(obj, solver);
        
        [obj] = genConstrIndicesIpopt(obj);
        
        [constrArray, constrInfos] = getConstrInfos(obj, solver);
        
        [constrArray, constrInfos] = getConstrInfosIpopt(obj);
        
        [z0] = getStartingPoint(obj, varargin);
        
        [obj] = setInitialGuess(obj, z0);
        
        
        
    end
        
    
end

