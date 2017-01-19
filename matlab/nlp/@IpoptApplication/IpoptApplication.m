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
        % @type struct
        Objective
        
        % A sturcture contains the information of constraints
        %
        % @type struct
        Constraint
        
        
        
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
            options.initialguess = 'typical';
            
            % default IPOPT options
            options.ipopt.mu_strategy      = 'adaptive';
            options.ipopt.max_iter         = 1000;
            options.ipopt.tol              = 1e-7;
            options.ipopt.linear_solver    = 'ma57';
            options.ipopt.ma57_automatic_scaling = 'yes';
            options.ipopt.linear_scaling_on_demand = 'no';
            
            if nlp.Options.DerivativeLevel == 2 
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
            
            obj.Options = options;
            obj = initialize(obj, nlp);
            
            
        end
        
        
        
        
        
        
        
        
        
            
        
    end
        
    % function definitions
    methods
        
        [obj] = initialize(obj, nlp);
        
        [sol, info] = optimize(obj, nlp);
        
        
        
        
    end
    
end

