classdef (Abstract) Kinematics < handle
    % Defines a scalar kinematic function of a rigid body model
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
    
    
    properties (Dependent)
       
        % A actual symbol that represents the symbolic expression of the
        % kinematic constraint in Mathematica.
        %
        % @type char
        symbol
        
        % A symbol that represents the symbolic expression of the Jacobian
        % the kinematic constraint in Mathematica. 
        %
        % @type char
        jac_symbol
        
        % A symbol that represents the symbolic expressions of the time
        % derivative of the kinematic constraint's Jacobian in Mathematica.
        %
        % @type char
        jacdot_symbol
    end
    
    
    
    properties (SetAccess=protected, GetAccess=public)
        
        
        % An unique name string that determines the symbolic expressions of
        % the kinematic constraint in Mathematica.
        %
        % It has to be an unique string so as to prevent potential naming
        % conflicts in Mathematica. A valid name must begin with a letter,
        % and must consists only of letters and numbers. So, e.g.
        % underscores other special characters are not allowed. 
        %
        % The actual symbol variable in Mathematica uses the name string as
        % a subscript, i.e., it assigns the symbolic expression of the
        % kinematic constraint to a variable name 'h["name"]' to prevent
        % potential naming conflicts. Similarly, it uses Jh["name"] and
        % dJh["name"] for the Jacobian and time derivative of the Jacobian.
        % You could print the symbolic expressions in matlab by calling
        % math(obj.symbol) or math_eval(obj.symbol)
        %
        % See also: symbol, jac_symbol, jacdot_symbol
        %
        % @type char
        name
        
        
        % A flag whether linearize the output or not. The actual output
        % will be the linearization of the functioni at q = 0.
        %
        % @type true
        linear
        
        
        
        
    end % properties
    
    
    methods
        
        function obj = Kinematics(name)
            % The constructor function
            %
            % Parameters:
            %  name: a string symbol that will be used to represent this
            %  constraints in Mathematica @type char 
            
                        
            % default settings        
            obj.linear = false;
            
            if nargin > 0
                if ~isempty(name)
                    obj = setName(obj, name);
                end
            end
            
        end
        
        function obj = setName(obj, name)
            % Sets the object name
            %
            % Parameters:
            %  name: a string symbol that will be used to represent this
            %  constraints in Mathematica @type char 
            
            
            % validate name string
            assert(ischar(name),'Kinematics:invalidNameStr','The name must be a string!');
            
            assert(isempty(regexp(name, '_', 'once'))&&isempty(regexp(name, '\W', 'once')),...
                'Kinematics:invalidNameStr', ...
                'Invalid name string, can NOT contain ''_'' or other special characters.');
            
            obj.name = name;
            
        end
        
        
        function obj = linearize(obj, linear, model)
            % Sets whether to linearize the function or not
            %
            % Parameters:
            %  linear: linearize the function if it is true, otherwise
            %  if false. @type logical
           
            if islogical(linear)
                obj.linear = linear;
                
                % if symbol expressions alreay exist, re-compile them
                if check_var_exist({obj.symbol,obj.jac_symbol,obj.jacdot_symbol})
                    compile(obj, model, true);
                end
                    
            else
                warning('invalid input.');
            end
        end
        
        function status = compile(obj, model, re_load)
            % This function computes the symbolic expression of the
            % kinematics constraints in Mathematica.
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
                % compile symbolic expressions
                
                kin_cmd_str = getKinMathCommand(obj);
                jac_cmd_str = getJacMathCommand(obj);
                jacdot_cmd_str = getJacDotMathCommand(obj);
                if obj.linear
                    
                    % first obtain the symbolic expression for the
                    % kinematic function
                    eval_math([obj.symbol,'=',kin_cmd_str,';']);
                    
                    % get the substitution rule for q = 0
                    eval_math('{qe0subs,dqe0subs} = GetZeroStateSubs[];')
                    
                    % compute the Jacobian at q = 0
                    eval_math([obj.jac_symbol,'=',jac_cmd_str,'/.qe0subs;']);
                    
                    % re-compute the linear function
                    eval_math('Qe = GetQe[];');
                    eval_math([obj.symbol,'=Flatten[',obj.jac_symbol,'.Qe];']);
                    
                    eval_math([obj.jacdot_symbol,'=',jacdot_cmd_str,';']);
                else                
                    eval_math([obj.symbol,'=',kin_cmd_str,';']);
                    eval_math([obj.jac_symbol,'=',jac_cmd_str,';']);
                    eval_math([obj.jacdot_symbol,'=',jacdot_cmd_str,';']);
                end
                
                
                status = true;
            end
        end
        
        
        function print(obj, file)
            % This function prints out the symbolic expression from the
            % Mathematica to Matlab screen. 
            %
            % @todo better implementation ...
            
            if nargin < 2 % print to screen
                if check_var_exist({obj.symbol,obj.jac_symbol,obj.jacdot_symbol})
                    fprintf('%s: \n',obj.symbol);
                    math(obj.symbol)
                    
                    fprintf('%s: \n',obj.jac_symbol);
                    math(obj.jac_symbol)
                    
                    fprintf('%s: \n',obj.jacdot_symbol);
                    math(obj.jacdot_symbol)
                else
                    warning('The symbolic expressions do not exist.');
                end
                
            else % print to a file
                
                
                if check_var_exist({obj.symbol,obj.jac_symbol,obj.jacdot_symbol})
                    
                    f = fopen(file, 'w+');
                    
                    kin = math(['InputForm[',obj.symbol,']']);
                    fprintf(f,'%s: \n',obj.symbol);
                    fprintf(f,kin);
                    fprintf(f,'\n \n \n');
                    
                    
                    jac = math(['InputForm[',obj.jac_symbol,']']);
                    fprintf(f,'%s: \n',obj.jac_symbol);
                    fprintf(f,jac);
                    fprintf(f,'\n \n \n');
                    
                    
                    jdot = math(['InputForm[',obj.jacdot_symbol,']']);
                    fprintf(f,'%s: \n',obj.jacdot_symbol);
                    fprintf(f,jdot);
                    fprintf(f,'\n \n \n');
                    
                    fclose(f);
                else
                    warning('The symbolic expressions do not exist.');
                end
            end
        end
        
        
    end % methods
    
    
    
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj)
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            %
            % There is no default command for any specific kinematic
            % constraint. All subclasses must overload this function.
            cmd = '$Aborted';
        end
        
        
        function cmd = getJacMathCommand(obj)
            % This function returns the Mathematica command to compile the
            % symbolic expression for the kinematic constraint's Jacobian.
            
            cmd    = ['ComputeKinJacobians[',obj.symbol,']'];
        end
        
        function cmd = getJacDotMathCommand(obj)
            % The function returns the Mathematica command to compile the
            % symbolic expressions for the time derivative of the kinematic
            % constraint's Jacobian.
            
            cmd    = ['D[',obj.jac_symbol,',t]'];
        end
        
        
    end % private methods
    
    
    methods
        function symbol = get.symbol(obj)
            % The Get function of the property 'symbol'
            symbol = ['h["',obj.name,'"]'];
        end
        function jac_symbol = get.jac_symbol(obj)
            % The Get function of the property 'jac_symbol'
            jac_symbol = ['Jh["',obj.name,'"]'];
        end
        
        function jacdot_symbol = get.jacdot_symbol(obj)
            % The Get function of the property 'jacdot_symbol'
            jacdot_symbol = ['dJh["',obj.name,'"]'];
        end
    end % get methods
    
end % classdef
