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
        
        
        % A structure contains the information of objective functions
        %
        % Required fields for objective:
        %  num_funcs: the number of sub-functions @type integer        
        %  funcs: a cell array contains the name of sub-functions @type
        %  char        
        %  jac_funcs: a cell array contains the name of the first-order
        %  derivative of sub-functions @type char
        %  nnz_jac: the total number of non-zeros in the entire Jacobian
        %  matrix @type integer
        %  dep_indices: a cell array contains a vector of the indices of all
        %  dependent variables @type colvec
        %  auxdata: a cell array of auxdata for each sub-functions @type
        %  cell
        %  nz_jac_rows: a vector of the row indices of non-zeros in the
        %  entire first-order derivative (Gradient) @type colvec
        %  nz_jac_cols: a vector of the column indices of non-zeros in the
        %  entire first-order derivative (Gradient) @type colvec        
        %  nz_jac_indices: a cell array contains a vector of the indices of
        %  the non-zeros of the Jacobian @type colvec
        %
        % Optional Fields for objective:
        %  hess_funcs: a cell array contains the name of the second-order
        %  derivative of sub-functions @type char 
        %  nnz_hess: the total number of non-zeros in the entire Hessian
        %  matrix @type integer
        %  nz_hess_rows: a vector of the row indices of non-zeros in the
        %  entire second-order derivative (Hessian) @type colvec
        %  nz_jac_cols: a vector of the column indices of non-zeros in the
        %  entire second-order derivative (Hessian) @type colvec        
        %  nz_hess_indices: a cell array contains a vector of the indices of
        %  the non-zeros of the Hessian @type colvec
        %  
        % @type struct
        objective
        
        % A sturcture contains the information of constraints
        %
        % Required fields for objective:
        %  num_funcs: the number of sub-functions @type integer        
        %  funcs: a cell array contains the name of sub-functions @type
        %  char
        %  constrIndices: a cell array contains a vector of the indices of
        %  the constraint among the entire NLP constraints @type colvec
        %  jac_funcs: a cell array contains the name of the first-order
        %  derivative of sub-functions @type char
        %  nnz_jac: the total number of non-zeros in the entire Jacobian
        %  matrix @type integer
        %  dep_indices: a cell array contains a vector of the indices of all
        %  dependent variables @type colvec
        %  auxdata: a cell array of auxdata for each sub-functions @type
        %  cell
        %  nz_jac_rows: a vector of the row indices of non-zeros in the
        %  entire first-order derivative (Gradient) @type colvec
        %  nz_jac_cols: a vector of the column indices of non-zeros in the
        %  entire first-order derivative (Gradient) @type colvec        
        %  nz_jac_indices: a cell array contains a vector of the indices of
        %  the non-zeros of the Jacobian @type colvec
        %
        % Optional Fields for objective:
        %  hess_funcs: a cell array contains the name of the second-order
        %  derivative of sub-functions @type char 
        %  nnz_hess: the total number of non-zeros in the entire Hessian
        %  matrix @type integer
        %  nz_hess_rows: a vector of the row indices of non-zeros in the
        %  entire second-order derivative (Hessian) @type colvec
        %  nz_jac_cols: a vector of the column indices of non-zeros in the
        %  entire second-order derivative (Hessian) @type colvec        
        %  nz_hess_indices: a cell array contains a vector of the indices of
        %  the non-zeros of the Hessian @type colvec
        % 
        % @type struct
        constraint
        
        
        
    end
    
    
    %% Public methods
    methods (Access = public)
        
        function obj = IpoptApplication(nlp, new_opts)
            % The default constructor function
            %
            % Parameters:
            %  nlp: the NLP problem object to be solved
            %  opts_in: the solver options
            
            
            obj = obj@SolverApplication();
           
            % ipopt options
            options = struct();
            options.initialguess = 'typical';
            
            % default IPOPT options
            options.ipopt.mu_strategy      = 'adaptive';
            options.ipopt.max_iter         = 1000;
            options.ipopt.tol              = 1e-7;
            options.ipopt.linear_solver    = 'ma57';
            options.ipopt.ma57_automatic_scaling = 'yes';
            options.ipopt.linear_scaling_on_demand = 'no';
            
            if nlp.options.derivative_level == 2 
                % user-defined Hessian function is provide
                options.ipopt.hessian_approximation = 'exact';
            else
                options.ipopt.hessian_approximation = 'limited-memory';
                options.ipopt.limited_memory_update_type = 'bfgs';  % {bfgs}, sr1
                options.ipopt.limited_memory_max_history = 10;  % {6}
            end
            
            if nargin > 1
                options.ipopt = struct_overlay(options.ipopt,new_opts,{'AllowNew',true});
            end
            
            obj.options = options;
            obj = initialize(obj, nlp);
            
            
        end
        
        
        
        
        
        
        
        
        
            
        
    end
        
    % function definitions
    methods
        
        [obj] = initialize(obj, nlp);
        
        [sol, info] = optimize(obj, nlp);
        
        
        
        
    end
    
end

