classdef NonlinearProgram < handle
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
        
        
        % The class option
        %
        % Required fileds of options:
        %  derivative_level: the user-defined derivative order (0, 1 or 2)
        %  to be used by a NLP solver. @type integer @default 1
        %  derivative_type:  
        %  
        % 
        % @type struct
        options 
        
        
        % The structure array contains all information regarding NLP
        % optimization variables
        %
        % @type NlpVariable
        var_array
        
                
        % A cell data stores objective functions
        %
        % @type cell
        objective_array
        
        % A cell data stores all constraints functions
        %
        % @type cell
        constr_array
        
        
        
    end
    
    properties 
        % The solution of the NLP problem
        sol
    end
    
    
    %% Public methods
    methods
        
        function obj = NonlinearProgram(opts)
            % The default class constructor function
            %
            % Parameters: 
            %  opts: non-default configuration options. It will overwrite
            %        the default options @type struct
            
            
            
            % default options
            obj.options = struct();
            obj.options.derivative_level = 1;
            obj.options.derivative_type = 'analytic';
            
            % if non-default options are specified, overwrite the default
            % options.
            if nargin ~= 0
                obj.options = struct_overlay(obj.options,opts);
            end
            
            % initialize the type of the variables
            obj.var_array = NlpVariable.empty();
            obj.objective_array  = NlpFunction.empty();
            obj.constr_array = NlpFunction.empty();
            
            
        end
        
    end
    
    %% Function definitions
    methods
        
        [obj] = addVariable(obj, varargin);
        
        [obj] = genVarIndices(obj);
        
        [obj] = addObjective(obj, funcs);
        
        [obj] = addConstraint(obj, funcs);
        
        [nVar, lowerbound, upperbound] = getVarInfo(obj);
        
        [x0] = getInitialGuess(obj, method);
        
        
        
    end
        
    
end

