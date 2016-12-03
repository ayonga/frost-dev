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
        expr
        
        % A array of Kinematic constraints objects that are dependent
        % variables of the kinematic epxression 
        %
        % @type Kinematics
        kins
        
        
    end % properties
    
    
    methods
        
        function obj = KinematicExpr(name, kins, expr, varargin)
            % The constructor function
            %
            % Parameters:
            %  name: a string name that will be used to represent this
            %  constraints in Mathematica @type char        
            %  kins: a cell of Kinematics object array @type Kinematics
            %  expr:A string representation of the symbolic expressions
            %  @type char
            %  linear: indicates whether linearize the original
            %  expressoin @type logical
            
            
            
            obj = obj@Kinematics(name, varargin{:});
            
            if nargin > 1
            
                % validate dependent arguments
                check_object = @(x) ~isa(x,'Kinematics');
                
                if any(cellfun(check_object,kins))
                    error('Kinematics:invalidObject', ...
                        'There exist non-Kinematics objects in the dependent variable list.');
                end
                
                obj.kins = kins;
                % validate symbolic expressions
                if isempty(regexp(expr, '_', 'once'))
                    obj.expr = expr;
                else
                    err_msg = 'The expression CANNOT contain ''_''.\n %s';
                    
                    error('Kinematics:invalidExpr', err_msg, expr);
                end
                
                
                
                % extract variable names
                var_names = cellfun(@(kin){kin.name},kins,'UniformOutput',false);
                % validate if symbolic variables in the expressions are members
                % of the dependent variables
                ret = eval_math(['CheckSymbols[',expr,',Flatten[',cell2tensor(var_names,'ConvertString',false),']]']);
                
                if ~strcmp(ret, 'True')
                    err_msg = ['Mathematica detected symbolic variables that are not defined.\n',...
                        'Following symbolic variables are detected by Mathematica: \n %s'];
                    
                    det_var = eval_math(['FindSymbols[',expr,']']);
                    
                    error('Kinematics:invalidExpr',err_msg, det_var);
                end
            end
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
