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
    
    %     methods (Abstract)
    %         [dimsOptVar, lb, ub, dimsConstr, cl, cu] = getNlpInfo(obj);
    %         % The function returns the dimension, upper/lower limits of NLP
    %         % variables and the dimension, upper/lower boundary values of NLP
    %         % constraints.
    %
    %         [z0, zl, zu, lambda] = getStartingPoint(obj, warm_start);
    %         % This function returns the starting point (i.e., the initial
    %         % guess) for the NLP iterations. If the 'warm_start' option is
    %         % enable, then it also returns the warm start values.
    %
    %     end
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
        
        
        function [obj] = addVariable(obj, name, dimension, varargin)
            % This method registers the information of an optimization
            % variable
            %
            % Parameters:
            %  name: name of the variable @type char
            %  dimension: dimension of the variable @type integer
            %  lb: lower limit @type colvec
            %  ub: upper limit @type colvec
            %
            % Syntex:
            %   nlp = addVariable(nlp, 'name', 10, 0, 1)
            %   
            
            if isempty(obj.optVars)
                obj.optVars = NlpVar(name, dimension, varargin{:});
            else
                % specifies the next entry point
                next_entry = numel(obj.optVars) + 1;
                
                % construct the optimization varibale information
                obj.optVars(next_entry) = NlpVar(name, dimension, varargin{:});
            end
            
        end
        
        function obj = genVarIndices(obj)
            % Generate indices for all optimization variables. It must be
            % run after registered all optimization variables
            
            index0 = 0;
            
            for i=1:length(obj.optVars)
                var = obj.optVars(i);
                
                obj.optVarIndices.(var.name) = ...
                    index0 + cumsum(ones(1,var.dimension));
                
                % updates offset
                index0 = obj.optVarIndices.(var.name)(end);
            end
            
            
        end
        
        function [obj] = addCost(obj, name, deps, extra)
            % This method registers the information of a NLP function as a
            % cost function
            %
            % Parameters:
            %  name: name of the variable @type char
            %  deps: a list of dependent variables @type cell
            %  extra: (optional) extra constant input argument for
            %  functions
            %
            %  @see NlpFcn
           
            % opt variables have to be registered before adding constraints
            assert(~isempty(obj.optVarIndices),...
                'NonlinearProgram:incorrectProcedure',...
                ['Cost function can be registered only after generated variables indices.\n',...
                'Please run genVarIndices first.\n']);
            
            if nargin < 4 % no extra argument is provided
                extra = [];
            end
            
            % construct the optimization varibale information
            new_cost  = NlpCost(name, extra, ...
                'withHessian', obj.options.withHessian);
            
            nDeps = numel(deps);
            depIndices = [];
            for i = 1:nDeps
                var    = deps{i};
                depIndices = [depIndices,...
                    obj.optVarIndices.(var)];
            end
            
            new_cost = setDependentIndices(...
                new_cost, depIndices);
            
            
            if isempty(obj.costArray)
                obj.costArray = new_cost;
            else
                % specifies the next entry point
                next_entry = numel(obj.costArray) + 1;
                
                obj.costArray(next_entry) = new_cost;
            end
        end
        
        
        
        
        function [obj] = addConstraint(obj, name, deps, dimension, cl, cu, extra)
            % This method registers the information of a NLP function as a
            % constraint
            %
            % Parameters:
            %  name: name of the variable @type char
            %  deps: a list of dependent variables @type cell
            %  dimension: the dimension of the constraint vector
            %  cl: the lower bound
            %  cu: the upper bound
            %  extra: (optional) extra input argument for functions
            %
            %  @see NlpConstr NlpFcn
            
            
            % opt variables have to be registered before adding constraints
            assert(~isempty(obj.optVarIndices),...
                'NonlinearProgram:incorrectProcedure',...
                ['Constraint can be registered only after generated variables indices.\n',...
                'Please run genVarIndices first.\n']);
            
            if nargin < 7
                extra = [];
            end
            
            % construct the optimization varibale information
            new_constr  = NlpConstr(name, dimension, cl, cu, extra, ...
                'withHessian', obj.options.withHessian);
            
            nDeps = numel(deps);
            depIndices = [];
            for i = 1:nDeps
                var    = deps{i};
                depIndices = [depIndices,...
                    obj.optVarIndices.(var)];
            end
            
            new_constr = setDependentIndices(...
                new_constr, depIndices);
            
            if isempty(obj.constrArray)
                obj.constrArray = new_constr;
            else
                % specifies the next entry point
                next_entry = numel(obj.constrArray) + 1;
                
                obj.constrArray(next_entry) = new_constr;
            end
        end
        
        function [dimOptVar, lb, ub] = getVarInfos(obj)
            % The function returns the dimension, upper/lower limits of NLP
            % variables.
            %
            % Return values:
            %  dimOptVar: the total dimension of all NLP variables @type
            %  integer
            %  lb: the lower limits @type colvec
            %  ub: the upper limits @type colvec
            
            assert(~isempty(obj.optVars),['No variable is definied.\n',...
                'Please define NLP variables first.\n']);
            
            dimOptVar = sum([obj.optVars.dimension]);
            
            lb = vertcat(obj.optVars.lb);
            ub = vertcat(obj.optVars.ub);
            
        end
        
        function obj = genCostIndices(obj)
            % This function generates the indexing information for cost
            % functions
            
            nCosts = numel(obj.costArray);
            
            jIndex0 = 0;
            hIndex0 = 0;
            
            for i=1:nCosts
                cost = obj.costArray(i);
                cost = setJacIndices(cost, jIndex0);
                
                % update offset
                if ~isempty(cost.j_index)
                    jIndex0 = cost.j_index(end);
                end
                
                if obj.options.withHessian
                    cost = setHessIndices(cost, hIndex0);
                    if ~isempty(cost.h_index)
                        hIndex0 = cost.h_index(end);
                    end
                end
                obj.costArray(i) = cost;
                
            end
            
        end
        
        function [costArray, costInfos] = getCostInfos(obj)
            % This function returns the indexing information of the cost
            % function array, including the Gradient and Hessian (if
            % applicable) sparse structures.
            %
            % Return values:
            %  costArray: An array of cost function @type NlpCost
            %  costInfos: A structure contains other pre-computed
            %  information regarding cost array. @type struct
            %
            % Required fields of costInfos:
            %  nnzGrad: The number of nonzero entries in the objective
            %  gradient vector @type integer            
            %  gradSparseIndices: row and column indices of the  nonzero
            %  entries in the sparse Gradient vector @type matrix
            %  nnzHess: The number of nonzero entries in the cost portion
            %  of the Hessian @type integer
            %  hessSparseIndices: row and column indices of the nonzero
            %  entries in the sparse Hessian matrix associated with the
            %  cost function @type matrix
            
            % generate indexing first
            obj = genCostIndices(obj);
            
            
            nCosts  = numel(obj.costArray);
            nnzGrad = sum([obj.costArray.nnzJac]);
            
            gradSparseIndices = ones(nnzGrad,2);
            
            for i=1:nCosts
                cost = obj.costArray(i);
                jac_struct = cost.jac_struct;
                j_index = cost.j_index;
                dep_indices = cost.deps;
                
                
                gradSparseIndices(j_index,2) = dep_indices(jac_struct(:,2));
            end
            
            if obj.options.withHessian
                nnzHess = sum([obj.costArray.nnzHess]);
                hessSparseIndices = ones(nnzHess,2);
                
                for i=1:nCosts
                    cost = obj.costArray(i);
                    hess_struct = cost.hess_struct;
                    h_index = cost.h_index;
                    dep_indices = cost.deps;
                    
                    if ~cost.is_linear
                        hessSparseIndices(h_index,1) = dep_indices(hess_struct(:,1));
                        hessSparseIndices(h_index,2) = dep_indices(hess_struct(:,2));
                    end
                end
            else
                nnzHess = [];
                hessSparseIndices = [];
            end
            
            costArray = obj.costArray;
            
            costInfos = struct();
            costInfos.nnzGrad = nnzGrad;
            costInfos.gradSparseIndices = gradSparseIndices;
            costInfos.nnzHess = nnzHess;
            costInfos.hessSparseIndices = hessSparseIndices;
        end
        
        
        function obj = genConstrIndices(obj, solver)
            % This function generates the indexing information for
            % constraints
            %
            % @note Indexing NLP constraints depends on different NLP
            % solver being used. By default, we assume 'ipopt' being used,
            % with which all constraints are catagorized into one big
            % group. If 'fmincon' being used, then there will be
            % linear/nonlinear and equality/inequality constraints, and
            % each group of constraints are indexed separately.
            %
            % Parameters:
            %  solver: a string indicates the NLP solver being used @type
            %  char @default 'ipopt'
            
            
            if nargin < 2 % default solver 'ipopt'
                solver = 'ipopt';
            end
                
            switch solver
                case 'ipopt'
                    obj = genConstrIndicesIpopt(obj);
                case 'fmincon'
                    %| @todo implement indexing function for fmincon
                case 'snopt'
                    %| @todo implement indexing function for snopt
                otherwise
                    error('%s is not supported in the current version.\n',solver);
            end
            
            
        end
        
        function obj = genConstrIndicesIpopt(obj)
            % This function generates the indexing information for
            % constraints for IPOPT
           
            
            nConstrs = numel(obj.constrArray);
            
            cIndex0 = 0;
            jIndex0 = 0;
            hIndex0 = 0;
            
            for i=1:nConstrs
                constr = obj.constrArray(i);
                % set the indices for constraints and non-zero Jacobian
                % entries
                constr = setConstrIndices(constr, cIndex0);
                constr = setJacIndices(constr, jIndex0);
                
                % update the initial offset
                if ~isempty(constr.c_index)
                    cIndex0 = constr.c_index(end);
                end
                
                if ~isempty(constr.j_index)
                    jIndex0 = constr.j_index(end);
                end
                
                % if Hessian functions are provided, updated indices
                if obj.options.withHessian
                    constr = setHessIndices(constr, hIndex0);
                    if ~isempty(constr.h_index)
                        hIndex0 = constr.h_index(end);
                    end
                end
                obj.constrArray(i) = constr;
                
            end
        end
        
        
        function [constrArray, constrInfos] = getConstrInfos(obj, solver)
            % This function returns the indexing information of the
            % constraints function array, including the Gradient and
            % Hessian (if applicable) sparse structures.
            %
            % @note Indexing NLP constraints depends on different NLP
            % solver being used. By default, we assume 'ipopt' being used,
            % with which all constraints are catagorized into one big
            % group. If 'fmincon' being used, then there will be
            % linear/nonlinear and equality/inequality constraints, and
            % each group of constraints are indexed separately.
            %
            % Parameters:
            %  solver: a string indicates the NLP solver being used @type
            %  char @default 'ipopt'
            
            
            
            
            if nargin < 2 % default solver 'ipopt'
                solver = 'ipopt';
            end
            
            obj = genConstrIndices(obj, solver);
                
            switch solver
                case 'ipopt'
                    [constrArray, constrInfos] = getConstrInfosIpopt(obj);
                case 'fmincon'
                    %| @todo implement indexing function for fmincon
                case 'snopt'
                    %| @todo implement indexing function for snopt
                otherwise
                    error('%s is not supported in the current version.\n',solver);
            end
            
            
        end
        
        function [constrArray, constrInfos] = getConstrInfosIpopt(obj)
            % This function returns the indexing information of the
            % constraints function array, including the Gradient and
            % Hessian (if applicable) sparse structures.
            %
            % Return values:
            %  constrArray: An array of constraints @type NlpConstr
            %  constrInfos: A structure contains other pre-computed
            %  information regarding constraints array. @type struct
            %
            % Required fields of constrInfos:
            %  dimsConstr: The dimension of constraints @type integer
            %  cl: The lower bound of constraints @type colvec
            %  cu: The upper bound of constraints @type colvec
            %  nnzJac: The number of nonzero entries in the objective
            %  gradient vector @type integer
            %  gradSparseIndices: row and column indices of the  nonzero
            %  entries in the sparse Gradient vector @type matrix
            %  nnzHess: The number of nonzero entries in the cost portion
            %  of the Hessian @type integer
            %  hessSparseIndices: row and column indices of the nonzero
            %  entries in the sparse Hessian matrix associated with the
            %  cost function @type matrix
            
            nConstr  = numel(obj.constrArray);
            
            % dimension of the entire constraints vector
            dimConstr = sum([obj.constrArray.dims]);
            
            % number of non-zero elements in the Jacobian matrix
            nnzJac = sum([obj.constrArray.nnzJac]);
            
            % pre-allocation
            jacSparseIndices = ones(nnzJac,2);
            cl = zeros(dimConstr,1);
            cu = zeros(dimConstr,1);
            
            for i=1:nConstr
                constr = obj.constrArray(i);
                
                % sparse structure of the Jacobian matrix
                jac_struct = constr.jac_struct;
                % get indices of the constraint
                c_index = constr.c_index;
                % get jacobian entry indices
                j_index = constr.j_index;
                % get indices of dependent variables
                dep_indices = constr.deps;

                % row indices of non-zero entries
                jacSparseIndices(j_index,1) = c_index(jac_struct(:,1));
                % column indices of non-zero entries
                jacSparseIndices(j_index,2) = dep_indices(jac_struct(:,2));
                
                
                cl(c_index,1) = constr.cl;
                cu(c_index,1) = constr.cu;
            end
            
            if obj.options.withHessian
                % number of non-zero elements in the Hessian matrix
                nnzHess = sum([obj.constrArray.nnzHess]);
                % pre-allocation
                hessSparseIndices = ones(nnzHess,2);
                
                for i=1:nConstr
                    constr = obj.constrArray(i);
                    
                    % sparse structure of the Hessian matrix
                    hess_struct = constr.hess_struct;
                    % get indices of non-zero entries of Hessian matrix
                    h_index = constr.h_index;
                    % get indices of dependent variables
                    dep_indices = constr.deps;
                    
                    if ~constr.is_linear
                        hessSparseIndices(h_index,1) = dep_indices(hess_struct(:,1));
                        hessSparseIndices(h_index,2) = dep_indices(hess_struct(:,2));
                    end
                end
            else
                nnzHess = [];
                hessSparseIndices = [];
            end
            
            constrArray = obj.constrArray;
            constrInfos = struct();
            constrInfos.dimConstr = dimConstr;
            constrInfos.cl = cl;
            constrInfos.cu = cu;
            constrInfos.nnzJac = nnzJac;
            constrInfos.jacSparseIndices = jacSparseIndices;
            constrInfos.nnzHess = nnzHess;
            constrInfos.hessSparseIndices = hessSparseIndices;
        end
        
        
        function [z0] = getStartingPoint(obj, varargin)
            % Returns an initial guess for the NLP
           
            z0 = obj.z0;
        end
        
        function obj = setInitialGuess(obj, z0)
            obj.z0 = z0;
        end
    end
        
    
end

