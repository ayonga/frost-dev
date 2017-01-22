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
        %  DerivativeLevel: the user-defined derivative order (0, 1 or 2)
        %  to be used by a NLP solver. @type integer @default 1
        %  DerivativeType:  
        %  
        % 
        % @type struct
        Options 
        
        
        % The cell array contains all information regarding NLP
        % optimization variables
        %
        % @type cell
        VariableArray
        
                
        % A cell array data stores objective functions
        %
        % @type cell
        CostArray
        
        % A cell array data stores all constraints functions
        %
        % @type cell
        ConstrArray
        
        
        
    end
    
    properties 
        % The solution of the NLP problem
        Sol
    end
    
    
    %% Public methods
    methods
        
        function obj = NonlinearProgram(varargin)
            % The default class constructor function
            %
            % Parameters: 
            %  varargin: non-default configuration options. It will overwrite
            %        the default options @type struct
            
            
            
            % default options
            obj.Options = struct();
            obj.Options.DerivativeLevel = 1;
            obj.Options.DerivativeType = 'Analytic';
            
            % if non-default options are specified, overwrite the default
            % options.
            obj.Options = setOption(obj, varargin{:});
            
            % initialize the type of the variables
            obj.VariableArray = NlpVariable.empty();
            obj.CostArray  = NlpFunction.empty();
            obj.ConstrArray = NlpFunction.empty();
            
            
        end
        
    end
    
    %% Function definitions
    methods
        
        [obj] = addVariable(obj, varargin);
        
        [obj] = updateVarIndices(obj);
        
        [obj] = addObjective(obj, funcs);
        
        [obj] = addConstraint(obj, funcs);
        
        [nVar, lowerbound, upperbound] = getVarInfo(obj);
        
        [x0] = getInitialGuess(obj, method);
        
        
        
    end
        
    
end

