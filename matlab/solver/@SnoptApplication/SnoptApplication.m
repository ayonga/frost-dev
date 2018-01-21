classdef SnoptApplication < SolverApplication
    % SnoptApplication defines an interface application class for SNOPT solvers
    % 
    %
    % @author Jacob Reher @date 11/9/2017
    % 
    % Copyright (c) 2017, AMBER Lab
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
        
        function obj = SnoptApplication(nlp, new_opts)
            % The default constructor function
            %
            % Parameters:
            %  nlp: the NLP problem object to be solved 
            %  @type NonlinearProgram
            %  new_opts: the new solver options @type struct
            
            
            obj = obj@SolverApplication();
           
            % snopt options
            options.initialguess = 'typical';
            
            % default SNOPT options
            options.snopt.name = nlp.Name;
            
            if nargin > 1
                options.snopt = struct_overlay(options.snopt,new_opts,{'AllowNew',true});
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

