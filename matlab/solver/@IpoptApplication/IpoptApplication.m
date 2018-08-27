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
        
        
        % The nonlinear programming object
        %
        % @type NonlinearProgram
        Nlp
    end
    
    
    %% Public methods
    methods (Access = public)
        
        function obj = IpoptApplication(nlp, new_opts)
            % The default constructor function
            %
            % Parameters:
            %  nlp: the NLP problem object to be solved 
            %  @type NonlinearProgram
            %  new_opts: the new solver options @type struct
            
            
            obj = obj@SolverApplication();
           
            % ipopt options
            options.initialguess = 'typical';
            
            % default IPOPT options
            options.ipopt.mu_strategy      = 'adaptive';
            options.ipopt.max_iter         = 1000;
            options.ipopt.tol              = 1e-3;
            options.ipopt.linear_solver    = 'ma57';
            options.ipopt.ma57_automatic_scaling = 'yes';
            options.ipopt.linear_scaling_on_demand = 'no';
            options.ipopt.ma57_pre_alloc = 2;
            %             options.ipopt.alpha_for_y = 'bound-mult';
            options.ipopt.recalc_y = 'yes';
            options.ipopt.recalc_y_feas_tol = 1e-3;
            %             options.ipopt.bound_relax_factor = 1e-3;
            %             options.ipopt.fixed_variable_treatment = 'RELAX_BOUNDS';
            %             options.ipopt.derivative_test = 'first-order';
            %             options.ipopt.point_perturbation_radius = 0;
            %             options.ipopt.derivative_test_perturbation = 1e-8;
            % options.ipopt.derivative_test_print_all = 'yes';


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
            
            if exist(['sparse2.',mexext],'file') == 3
                options.UseMexSparse = true;
            else
                options.UseMexSparse = false;
            end
            
            obj.Options = options;
            obj.Nlp = nlp;
            obj = initialize(obj);
            
            
        end
        
        
        
        
        
        
        
        
        
            
        
    end
        
    % function definitions
    methods
        
        [obj] = initialize(obj);
        
        [sol, info] = optimize(obj, x0);
        
        
        
        
    end
    
end

