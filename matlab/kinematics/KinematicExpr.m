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
            
            
            
            obj = obj@Kinematics(name);
            
            
            p = inputParser();
            p.addParameter('linear', obj.linear, @islogical);
            parse(p, varargin{:});
            obj.linear = p.Results.linear;
            
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
            ret = eval_math(['CheckSymbols[',expr,',ToExpression[',cell2tensor(var_names),']]']);
            
            if ~strcmp(ret, 'True')
                err_msg = ['Mathematica detected symbolic variables that are not defined.\n',...
                    'Following symbolic variables are detected by Mathematica: \n %s'];
                
                det_var = eval_math(['FindSymbols[',expr,']']);
                
                error('Kinematics:invalidExpr',err_msg, det_var);
            end
               
        end
        
        
        function status = compile(obj, model, re_load)
            % This function computes the symbolic expression of the
            % kinematics constraints in Mathematica.
            %
            % The compilation for KinematicExpr requires complex
            % computations, hence, we overload the superclass method here.
            %
            % Parameters:
            %  model: the rigid body model @type RigidBodyModel
            %  re_load: re-evaluate the symbolic expression @type logical
            
            if nargin < 3
                re_load = false;
            end
            
            status = true;
            
            
            if ~ checkFlag(model, '$ModelInitialized')
                warning(['''%s'' has NOT been initialized in Mathematica.\n',...
                    'Please call initialize(model) first\n',...
                    'Aborting ...\n'], model.name);
                status = false;
                return;
            end
            
            if ~ check_var_exist({obj.symbol,obj.jac_symbol,obj.jacdot_symbol}) || re_load
                
                % first compile dependent kinematics constraints
                cellfun(@(x) compile(x, model), obj.kins);
                
                % clear variables
                eval_math('Clear[expr, vars, Jhmat, Jhexp];');
                
                
                
                var_names = cellfun(@(kin){kin.name},obj.kins);
                % validate if symbolic variables in the expressions are members
                % of the dependent variables
                ret = eval_math(['CheckSymbols[',obj.expr,',ToExpression[',cell2tensor(var_names),']]']);
                
                if ~strcmp(ret, 'True')
                    err_msg = ['Mathematica detected symbolic variables that are not defined.\n',...
                        'Following symbolic variables are detected by Mathematica: \n %s'];
                    
                    det_var = eval_mat('FindSymbols[',obj.expr,']');
                    
                    error('Kinematics:invalidExpr',err_msg, det_var);
                else
                    % find symbolic varaibles in the expression
                    eval_math('vars = FindSymbols[expr];');
                end
                
                
                % assign expressions to a Mathmatica expression 'expr'
                eval_math(['expr=',obj.expr]);
                % compute compound expression and replace symbolic
                % variables with actual expressions
                eval_math([obj.symbol,'=expr/.Table[v -> h[ToString[v]], {v, vars}];']);
                
                % construct Jacobian matrix of dependent variables
                eval_math('Jhmat = Table[Flatten@Jh[ToString[v]], {v, vars}];');
                % compute partial derivatives and replace the symbolic
                % variables with the actual expressions
                eval_math('Jhexp = D[Flatten[{expr}], {Flatten[vars], 1}]/. Table[v -> First@h[ToString[v]], {v, vars}];');
                
                
                if obj.linear
                    % get the substitution rule for q = 0
                    eval_math('{qe0subs,dqe0subs} = GetZeroStateSubs[];')
                    % use chain rules to construct the final Jacobian matrix
                    eval_math([obj.jac_symbol,'=(Jhexp.Jhmat)/.qe0subs;']);
                    % re-compute the linear function
                    eval_mat('Qe = GetQe[];');
                    eval_math([obj.symbol,'=Flatten[',obj.jac_symbol,'.Qe];']);
                else
                    % use chain rules to construct the final Jacobian matrix
                    eval_math([obj.jac_symbol,'=Jhexp.Jhmat;']);
                end
                
                % compute time derivatives of the Jacobian matrix
                cmd = getJacDotMathCommand(obj);
                eval_math(cmd);
                
                % clear variables
                eval_math('Clear[expr, vars, Jhmat, Jhexp];');
                status = true;
            end
            
        end
        
    end % methods
    
    
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
