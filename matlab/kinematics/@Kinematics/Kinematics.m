classdef (Abstract) Kinematics
    % Defines a kinematic function of a rigid body model
    % 
    %
    % @author ayonga @date 2016-09-23
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
  
        
    
    
    properties
        
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
        Name
        
        
        % A flag whether linearize the output or not. The actual output
        % will be the linearization of the functioni at q = 0.
        %
        % @type logical
        Linearize
        
    end % properties
    
    
    methods
        
        function obj = Kinematics(varargin)
            % The constructor function
            %
            % Parameters: 
            %   varargin: it could be a struct has the same fields as this
            %   class or name-value pair arguments. The syntax would be
            %   similar to construct a struct in Matlab. Use either
            %   @verbatim kin = Kinematics('Prop1', Value1,'Prop2',Value2,...); @endverbatim
            %   or 
            %   @verbatim kin = Kinematics(KinStruct); @endverbatim
            %
            % See also: struct
            
            if nargin < 1
                return;
            end
                        
            
            
            objStruct = struct(varargin{:});
            % check name type
            if isfield(objStruct, 'Name')
                obj.Name = objStruct.Name;
            else
                if ~isstruct(varargin{1})
                    error('The ''Name'' must be specified in the argument list.');
                else
                    error('The input structure must have a ''Name'' field');
                end
            end
            
            
            
            if isfield(objStruct, 'Linearize')
                obj.Linearize = objStruct.Linearize;
            else
                obj.Linearize = false;
            end
            
        end
        
        
        
        
        
        function dim = getDimension(obj)
            % Returns the dimension of the kinematic function. 
            % By default, we assume the dimension of a kinematic function
            % is 1, unless this method is overloaded by subclasses
            
            dim = 1;
        end
       
        
        
    end % methods
    
    %% Methods defined in separte files
    methods
        status = compile(obj, model, re_load);        
        
        status = export(obj, export_path, do_build)
        
        printExpression(obj, file);
    end
    
    
    %% private properties
    properties (Hidden, GetAccess = protected)
        
        % A flag for whether the ''Linearize'' option is changed
        %
        % @type logical
        LinearizeFlagChanged
        
    end
    
    
    %% dependent properties
    properties (Dependent)
        
        % A actual symbol that represents the symbolic expression of the
        % kinematic constraint in Mathematica.
        %
        % Required fields of Symbols:
        % Kin: the kinematic function @type char
        % Jac: the Jacobian of the function `\partial{Kin}/\partial{q}`
        % @type char
        % JacDot: the time derivative of Jacobian @type char
        %
        % @type struct
        Symbols
        
        
        % File names of the kinematic functions. 
        %
        % Each field of ''Funcs'' specifies the name of a function that
        % used for a certain computation of the domain.
        %
        % Required fields of Funcs:
        %   Kin: a string of the function that computes the
        %   value of holonomic constraints @type char
        %   Jac: a string of the function that computes the
        %   jacobian of holonomic constraints @type char
        %   JacDot: a string of the function that computes time derivatives of the
        %   jacobian matrix of holonomic constraints @type char
        %
        % @type struct
        Funcs
    end
    
    %% get/set methods
    methods
        
        function Symbols = get.Symbols(obj)
            
            assert(~isempty(obj.Name),'The ''Name'' of the object is empty');
            
            Symbols = struct(...
                'Kin',['$h["',obj.Name,'"]'],...
                'Jac',['$Jh["',obj.Name,'"]'],...
                'JacDot',['$dJh["',obj.Name,'"]']); 
        end
        
        function Symbols = get.Funcs(obj)
            
            assert(~isempty(obj.Name),'The ''Name'' of the object is empty');
            
            Symbols = struct(...
                'Kin',['h_',obj.Name],...
                'Jac',['Jh_',obj.Name],...
                'JacDot',['dJh_',obj.Name]); 
        end
        
        function obj = set.Linearize(obj, flag)
            % if symbol expressions alreay exist, re-compile them
            
            if isempty(obj.Linearize)
                obj.Linearize = flag;
            else
                if obj.Linearize ~= flag
                    obj.LinearizeFlagChanged = true; %#ok<MCSUP>
                end
                
                obj.Linearize = flag;
            end
            
        end
        
        
        function obj = set.Name(obj, name)
            % Set function for ''Name'' property
            %
            assert(ischar(name), 'The name must be a string.');
            
            % validate name string
            assert(isempty(regexp(name, '_', 'once'))&&isempty(regexp(name, '\W', 'once')),...
                'Kinematics:invalidNameStr', ...
                'Invalid name string, can NOT contain ''_'' or other special characters.');
            
            obj.Name = name;
            
            
        end
    end
    
    methods (Access = protected)
        
        function cmd = getKinMathCommand(obj, model) %#ok<INUSD>
            % This function returns he Mathematica command to compile the
            % symbolic expression for the kinematic constraint.
            %
            % There is no default command for any specific kinematic
            % constraint. All subclasses must overload this function.
            cmd = '$Aborted';
        end
        
        
        function cmd = getJacMathCommand(obj, model) %#ok<INUSD>
            % This function returns the Mathematica command to compile the
            % symbolic expression for the kinematic constraint's Jacobian.
            
            cmd    = ['ComputeKinJacobians[',obj.Symbols.Kin,']'];
        end
        
        function cmd = getJacDotMathCommand(obj)
            % The function returns the Mathematica command to compile the
            % symbolic expressions for the time derivative of the kinematic
            % constraint's Jacobian.
            
            cmd    = ['D[',obj.Symbols.Jac,',t]'];
        end
        
        
    end % private methods
    
    
    
end % classdef
