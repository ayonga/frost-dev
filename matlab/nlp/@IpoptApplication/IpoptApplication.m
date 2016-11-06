classdef IpoptApplication < SolverApplication
    % IpoptApplication defines an interface application class for IPOPT solvers
    % 
    %
    % @author Ayonga Hereid @date 2016-10-22
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
   
    %% Private properties
    properties (Access=public)
        
        % The dimension of the NLP decision (optimization) variables
        % 
        % @type integer
        dimVariable
        
        % The lower limits of the optimization variables
        %
        % @type colvec
        lb
        
        % The upper limits of the optimization variables
        %
        % @type colvec
        ub
        
        % Contains the information of registered cost functions in the form
        % of NlpCost array
        %
        % @type NlpCost
        costArray
        
        % Contains the information of registered constraints in the form of
        % NlpConstraint array
        %
        % @type NlpConstraint
        constrArray
        
        % The number of nonzero entries in the objective gradient vector
        % 
        % @type integer
        nnzGrad
        
        % Row and column indices of the  nonzero entries in the sparse
        % Gradient vector 
        %
        % @type matrix
        gradNonzeroIndex
        
        % The dimension of constraints 
        %
        % @type integer
        dimConstraint
        
        % The lower bound of constraints 
        %
        % @type colvec
        cl
        
        % The upper bound of constraints 
        % 
        % @type colvec
        cu
        
        % The number of nonzero entries in the constraint Jacobian matrix
        %
        % @type integer
        nnzJac
        
        % Row and column indices of the  nonzero entries in the sparse
        % Jacobian matrix 
        %
        % @type matrix
        jacNonzeroIndex
        
        % The number of nonzero entries in the cost portion of the Hessian
        %
        % @type integer
        nnzHess
        
        % Row and column indices of the nonzero entries in the sparse
        % Hessian matrix 
        %
        % @type matrix
        hessNonzeroIndex
        
        
    end
    
    %% Public properties
    properties (Access = public)
        % It stores the most recent solution
        %
        % @type colvec
        sol
        
        
    end
    
    %% Public methods
    methods (Access = public)
        
        function obj = IpoptApplication(nlp, opts_in)
            % The default constructor function
            %
            % Parameters:
            %  nlp: the NLP problem object to be solved
            %  opts_in: the solver options
           
            % ipopt options
            solver_opts = struct();
            solver_opts.mu_strategy      = 'adaptive';
            solver_opts.max_iter         = 1000;
            solver_opts.tol              = 1e-7;
            solver_opts.hessian_approximation = 'exact';
            solver_opts.limited_memory_update_type = 'bfgs';  % {bfgs}, sr1
            solver_opts.limited_memory_max_history = 10;  % {6}
            solver_opts.linear_solver = 'ma57';
            solver_opts.ma57_automatic_scaling = 'yes';
            solver_opts.linear_scaling_on_demand = 'no';
            
            if nargin > 1
                solver_opts = struct_overlay(solver_opts,opts_in,{'AllowNew',true});
            end
            
            obj = obj@SolverApplication(nlp, solver_opts);
            
            
            
        end
        
        
        
        
        
        
        
        
        
            
        
    end
        
    % function definitions
    methods
        
        [obj] = initialize(obj);
        
        [obj] = optimize(obj);
        
        
        [costArray] = indexCostArray(obj);        
        
        
        [constrArray] = indexConstraintArray(obj);
        
        
        
        
    end
    
end

