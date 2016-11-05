classdef (Abstract) SolverApplication
    % SolverApplication defines an abstract interface class for NLP solvers
    % 
    %
    % @author Ayonga Hereid @date 2016-10-21
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    %% Public properties
    properties (Access = public)
        
        
    end
    
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        
        % The nonlinear programming problem object to be solved
        % 
        % @type NonlinearProgram        
        nlp
        
        % Solver options
        %
        % @type struct
        options
        
        % The info data of the most recent solution from the NLP solver
        %
        % @type struct
        info
    end
    
    methods (Abstract)
        initialize(obj)
        
        
        optimize(obj)
        % An abstract method that run the NLP optimization
        
        reOptimizeNLP(obj)
        
        
    end
   
    methods
        function obj = SolverApplication(nlp, options)
            % The default constructor function
            %
            % Parameters:
            %  nlp: the NLP problem object to be solved
            %  options: the solver options
            
            obj.nlp = nlp;
            obj.options = options;
            
        end
        
        
    end
    
end

