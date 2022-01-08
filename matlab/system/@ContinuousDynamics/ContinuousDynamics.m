classdef ContinuousDynamics < DynamicalSystem
    % Continuous state dynamic system governed by differential equations.
    %
    % It could be either a
    % first order system with the form:
    % \f{eqnarray*}{
    % Mmat(x)\dot{x} + Fvec(x) = Gvec(x)
    % \f}
    % or a second order system with the form:
    % \f{eqnarray*}{
    % Mmat(q)\ddot{q} + Fvec(q,\dot{q}) = Gvec(q,u)
    % \f}
    % 
    % Further, if the inputs (u) are affine, the system can be written as
    % either for first order system of the form:
    % \f{eqnarray*}{
    % Mmat(x)\dot{x} + Fvec(x) = Gmap(x) u
    % \f}
    % or a second order system of the form:
    % \f{eqnarray*}{
    % Mmat(x)\ddot{x} + Fvec(x,\dot{x}) = Gmap(x) u
    % \f}
    %    
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
    
    
    
    % callback function handle properties to implement object specific
    % funtionalities outside of the class without making a new subclass
    properties
        
        % pre-process function handle of the object before the simulation 
        %
        % @note The function handle should have the syntax:
        % params = preProcess(sys, t, x, controller, params, varargin)
        %
        %
        %
        % @type function_handle
        PreIntegrationCallback 
        
        % pre-process function handle of the object after the simulation 
        %
        % @note The function handle should have the syntax:
        % params = postPorcess(sys, sol, controller, params, varargin)
        %
        % @type function_handle
        PostIntegrationCallback
        
        
        % function to compute the system dynamics
        %
        % @type function_handle
        calcDynamics
        
    end
    
    %%
    properties (SetAccess=protected)
        
        
        % The mass matrix Mmat(x) 
        %
        % @type cell
        Mmat
        
        
        
        % The cell array of the drift vector fields Fvec(x) SymFunction
        %
        % We split the Fvec into many sub-vectors Fvec[i], such that 
        % \f{eqnarray*}{
        % Fvec = \sum_i^N Fvec[i]
        % \f}
        % @type cell
        Fvec
        
        
        % The holonomic constraints of the dynamical system
        %
        % @type struct
        HolonomicConstraints = struct()
        
        
        % The unilateral constraints of the dynamical system
        %
        % @type struct
        UnilateralConstraints = struct()
        
        
        % The event functions
        %
        % The event functions are often subset of the unilateral
        % constraints defined on the system. For flexibility, we define
        % them separately.
        %
        % @type struct
        EventFuncs = struct()
        
    end
    
    
    
    %%
    methods
        function obj = ContinuousDynamics(name, type)
            % ContinuousDynamics(type, name, ...) construct a
            % ContinuousDynamics class object
            %
            % Parameters:            
            % name: the name of the system @type char            
            % dim: the dimension of the configuration space the
            % system (i.e., degrees of freedom) @type integer            
            % options.Eventname: the event name associated with the discrete map 
            % @type char
            % options.UserNlpConstraint: the function handle to enforce
            % user-defined NLP constraints @type function_handle
            
            arguments
                name char {mustBeValidVariableName}
                type char {mustBeMember(type,{'FirstOrder','SecondOrder'})}  
            end
            
            obj = obj@DynamicalSystem(name, type);
            
            switch type
                case 'FirstOrder'
                    obj.calcDynamics = @(obj,t,x,logger)firstOrderDynamics(obj,t,x,logger);
                case 'SecondOrder'
                    obj.calcDynamics = @(obj,t,x,logger)secondOrderDynamics(obj,t,x,logger);
            end
        end
        
        
        function obj = configureSystemStates(obj, bounds)
            
            if isempty(obj.Dimension) || obj.Dimension <= 0
                error('Failed to configure system states. The system dimension is either undefined or non-positive.');
            end
            dim = obj.Dimension;
            
            switch obj.Type
                case 'FirstOrder'
                    if isfield(bounds,'x')
                        lb = bounds.x.lb;
                        ub = bounds.x.ub;
                    else
                        lb = [];
                        ub = [];
                    end
                    x = StateVariable('x', dim, lb, ub);
                    setAlias(x,'Position and Velocity');
                    
                    
                    if isfield(bounds,'dx')
                        lb = bounds.dx.lb;
                        ub = bounds.dx.ub;
                    else
                        lb = [];
                        ub = [];
                    end
                    dx = StateVariable('dx', dim, lb, ub);
                    setAlias(dx, 'Velocity and Acceleration');
                    
                    
                    obj.addState(x,dx);
                    
                case 'SecondOrder'
                    
                    if isfield(bounds,'x')
                        lb = bounds.x.lb;
                        ub = bounds.x.ub;
                    else
                        lb = [];
                        ub = [];
                    end
                    x = StateVariable('x', dim, lb, ub);
                    setAlias(x, 'Position');
                    
                    
                    if isfield(bounds,'dx')
                        lb = bounds.dx.lb;
                        ub = bounds.dx.ub;
                    else
                        lb = [];
                        ub = [];
                    end
                    dx = StateVariable('dx', dim, lb, ub);
                    setAlias(dx, 'Velocity');
                    
                    
                    if isfield(bounds,'ddx')
                        lb = bounds.ddx.lb;
                        ub = bounds.ddx.ub;
                    else
                        lb = [];
                        ub = [];
                    end
                    ddx = StateVariable('ddx', dim, lb, ub);
                    setAlias(ddx, 'Acceleration');
                    
                    obj.addState(x,dx,ddx);
                otherwise
                    error('Failed to configure system states. The system type is either undefined or incorrect.');
            end
            
        end
        
        
    end
    
    
    methods
        function set.calcDynamics(obj, func)
            assert(isa(func,'function_handle'),'The callback function must be a function handle');
            assert(nargin(func) == 4, 'The callback function must have exactly four (model, t, x, logger) inputs.');
            %             assert(nargout(func) == 1, 'The callback function must have exactly one (xdot) output');
            obj.calcDynamics = func;
        end
        
    end
    
    methods
        nlp = imposeNLPConstraint(obj, nlp, varargin);
    end
    
    properties (Access=private, Hidden)
        % The function name of the Mmat
        %
        % @type char
        MmatName_
        
        % The function names of the Fvec
        %
        % @type cellstr
        FvecName_
    end
    
    methods (Static)
        function validateMassMatrix(obj, M)
            [nr,nc] = dimension(M);
            assert(nr==obj.Dimension && nc==obj.Dimension,...
                'The size of the mass matrix should be (%d x %d).',obj.Dimension,obj.Dimension);
            x = obj.States.x;
            assert((length(M.Vars)==1 && M.Vars{1} == x) ,...
                'The SymFunction (M) must be a function of only the state variable `x`.');
        end
        
        function validateDriftVector(obj, F)
            [nr,nc] = dimension(F);
            assert(nr==obj.Dimension && nc==1,...
                'The size of the drift vector (%s) should be (%d x %d).',F.Name, obj.Dimension, 1);
            
            vars = F.Vars;
            if strcmp(obj.Type,'SecondOrder') % second order system
                assert(length(vars)==2 && vars{1} == obj.States.x && vars{2}==obj.States.dx,...
                    'The SymFunction (%s) must be a function of states (x) and (dx).',F.Name);
            else % first order system
                assert(length(vars)==1 && vars{1} == obj.States.x,...
                    'The SymFunction (%s) must be a function of states (x).',F.Name);
            end
        end
    end
end

