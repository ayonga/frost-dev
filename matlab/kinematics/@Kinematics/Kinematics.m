classdef Kinematics
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
        Name
        
        
        % The dimensiona of the kinematic function
        %
        % @type integer
        Dimension
        
        % A set of options for the kinematic functions.
        %
        % Required fields of options:
        % linearize: A flag whether linearize the output or not. The actual output
        % will be the linearization of the functioni at q = 0. @type 
        % logical
        %
        % @type true
        Options
        
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
        
        
    end % properties
    
    
    methods
        
        function obj = Kinematics(name, varargin)
            % The constructor function
            %
            % Parameters: 
            %   name: a string symbol that will be used to represent this 
            %   constraints in Mathematica @type char                    
            %   varargin: Class options. 
            %   linearize: indicates whether linearize the original
            %   expressoin @type logical @default false
                        
            if nargin == 0
                return;
            end
            
            % check type
            assert(ischar(name), 'The name must be a string.');
            
            % validate name string            
            assert(isempty(regexp(name, '_', 'once'))&&isempty(regexp(name, '\W', 'once')),...
                'Kinematics:invalidNameStr', ...
                'Invalid name string, can NOT contain ''_'' or other special characters.');
            
            obj.Name = name;
            
            % create symbolic variables name
            obj.Symbols = struct(...
                'Kin',['$h["',obj.Name,'"]'],...
                'Jac',['$Jh["',obj.name,'"]'],...
                'JacDot',['$dJh["',obj.name,'"]']);
            
            % parse options
            p = inputParser;
            p.addParameter('Linearize', false, @islogical);
            
            parse(p, varargin{:});
            obj.Options = struct();
            obj.Options.Linearize = p.Results.Linearize;
            
        end
        
        
        
        
        
        
        
        
    end % methods
    
    %% Methods defined in separte files
    methods
        status = compileExpression(obj, model, re_load);
        
        
        printExpression(obj, file);
        
        obj = linearize(obj, linearize);
    end
    
    
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
    
    
    
end % classdef
