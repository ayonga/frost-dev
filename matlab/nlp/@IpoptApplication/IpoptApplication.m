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
    
   
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
       
        
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
            solver_opts.ipopt.mu_strategy      = 'adaptive';
            solver_opts.ipopt.max_iter         = 1000;
            solver_opts.ipopt.tol              = 1e-7;
            solver_opts.ipopt.hessian_approximation = 'limited-memory';
            solver_opts.ipopt.limited_memory_update_type = 'bfgs';  % {bfgs}, sr1
            solver_opts.ipopt.limited_memory_max_history = 10;  % {6}
            solver_opts.ipopt.linear_solver = 'ma57';
            solver_opts.ipopt.ma57_automatic_scaling = 'yes';
            solver_opts.ipopt.linear_scaling_on_demand = 'no';
            
            if nargin > 1
                solver_opts = struct_overlay(solver_opts,opts_in,{'AllowNew',true});
            end
            
            obj = obj@SolverApplication(nlp, solver_opts);
            
            
            
        end
        
        
        function obj = initialize(obj)
            
        end
        
        
        
        function obj = reOptimizeNLP(obj)
            
        end
        
        function obj = setOptions(obj, varargin)
            
        end
        
        function info = getInfo(obj)
            
            info = obj.info;
        end
        
        
            
        
    end
        
    methods
        
        obj = optimize(obj)
    end
    
end

