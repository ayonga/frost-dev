classdef (Abstract) DynamicalSystem < handle
    % An abstract superclass for affine dynamical systems.
    % 
    %
    %
    % Affine systems are dynamical control systems that are affine in the
    % inputs.
    %
    % @author ayonga @date 2017-02-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        % The unique name identification of the system
        %
        % @type char
        Name
        
        
        % The number of states
        %
        % @type double
        numState
        
        % The number of control inputs
        %
        % @type double
        numControl
        
        % The number of external inputs (disturbances)
        %
        % @type double
        numExternal
        
        
        % A structure that contains the symbolic representation of state
        % variables
        %
        % Required fields of States:
        %  x: the state variables x(t) @type SymVariable
        %  dx: the first order derivatives of X, i.e. xdot(t)
        %  @type SymVariable
        %
        % Optional fields of States:
        %  ddx: the second order derivatives of X , i.e. xddot(t) 
        %  @type SymVariable
        %
        % @type struct
        States
        
        % A structure that contains the symbolic representation of input
        % variables
        %
        % Required fields of Inputs:
        %  u: the control input variables u(t) @type SymVariable
        %
        % Optional fields of States:
        %  f: other external inputs, such as external constraints forces or
        %  disturbance forces F(t) @type SymVariable
        %
        % @type struct
        Inputs
        
        % The parameters of the system
        %
        % @type struct
        Params
        
        
        % The set of relative degree 1 virtual constraints (output) 
        %
        % @type struct
        RD1Output
        
        % The set of (vector) relative degree 2 virtual constraints
        % (output)
        %
        % @type struct
        RD2Output
        
        
        % A structure that contains the symbolic expression of the
        % dynamical equations
        %
        % Required fields of DynamicsEqn:
        %  M: the mass matrix M(x) @type SymExpression
        %  vf: the vector field f(x) @type SymExpression
        %  gf: the affine actuation map g(x) @type SymExpression
        %  G: the external force map G(x) @type SymExpression
        %
        % @type struct
        DynamicsEqn
        
        % A structure that contains the symbolic expression of the
        % constraints equations
        %
        % Required fields of DynamicsEqn:
        %  h: the constraint equation h(x) @type SymExpression
        %  Jh: the Jacobian of constraints Jh(x) w.r.t to the states
        %  @type SymExpression
        %  dJh:  the time derivative of the Jacobian of constraints
        %  Jh(x)  @type SymExpression
        %
        % @type struct
        ConstraintEqn
        
        
        % A structure that contains the symbolic functions that will be
        % used for trajectory optimization problem. 
        %
        % This property stores the system generic constraints, so that it
        % could prevent generate and compute the exact same symbolic
        % expression for the same system multiple times.
        %
        %
        % @type struct
        TrajOptFuncs
        
    end
    
    % methods defined in external files
    methods 
        % Add state variables
        obj = addState(obj, x, dx, ddx);
        
        % Add input variables
        obj = addInput(obj, u, F);
        
        % Add parameter variables
        obj = addParam(obj, varargin);
        
        % Add dynamical equations
        obj = dynamicsEquation(obj, M, vf, gf, G);
        
        % Add dynamical constraints equations
        obj = constrainedEquation(obj, h, Jh, dJh); 
    end
    
    
    methods
        function obj = DynamicalSystem(name)
            % The class construction function
            %
            % Parameters:
            
            assert(ischar(name),...
                'The name of the system must be a character vector.')
            
            obj.Name = name;
            
            obj.States = struct();
            obj.Inputs = struct();
            obj.Params = struct();
            
            
            
            
            obj.DynamicsEqn = struct();
            obj.ConstraintEqn = struct();
            
            %
            obj.TrajOptFuncs = struct();
            obj.TrajOptFuncs.Collocation = struct();
            obj.TrajOptFuncs.Dynamics = struct();
        end
        
    end
    
    
end

