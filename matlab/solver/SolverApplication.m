classdef (Abstract) SolverApplication < handle
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
    
    
    
    properties 
        
        % A structure for NLP solver options
        %
        % @type struct
        Options
        
    end
    
    methods (Abstract)
        
        % An abstract method that initialize the solver to be ready to
        % solve the given NLP problem
        initialize(obj, nlp);
        
        
        % An abstract method that run the NLP problem
        optimize(obj, nlp);
    end
   
    methods
        function obj = SolverApplication()
            % The default constructor function            
            
            obj.Options = struct;
        end
        
        
    end
    
end

