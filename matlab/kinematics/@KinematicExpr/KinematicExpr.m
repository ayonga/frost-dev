classdef KinematicExpr < Kinematics
    % Defines a kinematic constraint that expressed as a function of other
    % kinematic constraints.
    % 
    %
    % @author Ayonga Hereid @date 2016-09-23
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess=protected, GetAccess=public)
        
        % A string representation of the symbolic expressions
        %
        % @type char
        Expression
        
        % A array of Kinematic constraints objects that are dependent
        % variables of the kinematic epxression 
        %
        % @type Kinematics
        Dependents
        
        
    end % properties
    
    
    methods
        
        function obj = KinematicExpr(varargin)
            % The constructor function
            %
            % @copydetails Kinematics::Kinematics()
            %
            % See also: Kinematics
            
            
            
            obj = obj@Kinematics(varargin{:});
            if nargin == 0
                return;
            end
            % the dimension is always 1
            obj.Dimension = 1;
            objStruct = struct(varargin{:});
            
            if isfield(objStruct, 'Expression')
                obj.Expression = objStruct.Expression;
            end
            
            if isfield(objStruct, 'Dependents')
                obj.Dependents = objStruct.Dependents;
            end
        end
        
        
        function obj = set.Expression(obj, expr)
            
            % validate symbolic expressions
            if isempty(regexp(expr, '_', 'once'))
                obj.Expression = expr;
            else
                err_msg = 'The expression CANNOT contain ''_''.\n %s';                
                error('Kinematics:invalidExpr', err_msg, expr);
            end
            
        end
        
        function obj = set.Dependents(obj, deps)
            
            % validate dependent arguments
            check_object = @(x) ~isa(x,'Kinematics');
            
            if any(cellfun(check_object,deps))
                error('Kinematics:invalidObject', ...
                    'There exist non-Kinematics objects in the dependent variable list.');
            end
            
            check_dimension = @(x) (getDimension(x) ~= 1);
            if any(cellfun(check_dimension,deps))
                error('Kinematics:wrongDimension', ...
                    ['The dependent kinematic variable must be a scalar function.',...
                    'Use KinematicPosition or KinematicOrientation for positional variables instead.']);
            end
            
            obj.Dependents = deps;
        end
        
    end % methods
    
    %% Methods defined in separte files
    methods
        status = compileExpression(obj, model, re_load);
    end
    
    
    methods (Access = protected)
        
        % overload the default compile function
        % function cmd = getKinMathCommand(obj)
        % end
        
        % overload the default compile function
        % function cmd = getJacMathCommand(obj)
        % end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
