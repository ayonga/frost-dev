 classdef DynamicalSystem < handle
    % An superclass for dynamical systems. It could be either a
    % first order system with the form:
    % \f{eqnarray*}{
    % Mmat(x)\dot{x}= Fvec(x) + Gvec(x,u)
    % \f}
    % or a second order system with the form:
    % \f{eqnarray*}{
    % Mmat(x)\ddot{x}= Fvec(x,\dot{x}) + Gvec(x,u)
    % \f}
    % 
    % Further, if the inputs (u) are affine, the system can be written as
    % either for first order system of the form:
    % \f{eqnarray*}{
    % Mmat(x)\dot{x}= Fvec(x) + Gmap(x) u
    % \f}
    % or a second order system of the form:
    % \f{eqnarray*}{
    % Mmat(x)\ddot{x}= Fvec(x,\dot{x}) + Gmap(x) u
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
    
    properties
        % The unique name identification of the system
        %
        % @type char
        Name
        
        % The highest order of the state derivatives of the system
        %
        % @note The system could be either a 'FirstOrder' system or a
        % 'SecondOrder' system.
        %
        % @type char
        Type
        
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
        
        % The total number of system states
        %
        % @type double
        numState
        
        % A structure that contains the symbolic representation of input
        % variables
        %
        % @type struct
        Inputs
        
        % The parameters of the system
        %
        % @type struct
        Params
        
        % The mass matrix Mmat(x) 
        %
        % @type SymFunction
        Mmat
        
        
        % The cell array of the drift vector fields Fvec(x) SymFunction
        %
        % We split the Fvec into many sub-vectors Fvec[i], such that 
        % \f{eqnarray*}{
        % Fvec = \sum_i^N Fvec[i]
        % \f}
        % @type cell
        Fvec
        
        % The struct of input vector fields Gvec(x,u) SymFunction
        %
        % @type struct
        Gvec
        
        % The struct of input map Gmap(x) SymFunction
        %
        % @type struct
        Gmap
        
        
        
        % The holonomic constraints of the dynamical system
        %
        % @type struct
        HolonomicConstraints
        
        
        % The unilateral constraints of the dynamical system
        %
        % @type struct
        UnilateralConstraints
        
    end
    
    % methods defined in external files
    methods 
        % Add state variables
        obj = addState(obj, x, dx, ddx);
        
        % Add input variables
        obj = addInput(obj, name, inputs, map, varargin);
        
        % Remove input variables
        obj = removeInput(obj, input_name);
        
        % Add parameter variables
        obj = addParam(obj, varargin);
        
        % Remove parameter variables
        obj = removeParam(obj, param_name);
        
        % set the mass matrix M(x)
        obj = setMassMatrix(obj, M);
        
        % set the group of drift vector fields F(x) or F(x,dx)
        obj = setDriftVector(obj, vf);
        
        % add holonomic constraints
        obj = addHolonomicConstraint(obj, name, constr, jac);
        
        % remove holonomic constraints
        obj = removeHolonomicConstraint(obj, name);
        
        % add unilateral constraints
        obj = addUnilateralConstraint(obj, name, constr, deps);
        
        % remove unilateral constraints
        obj = removeUnilateralConstraint(obj, name);
        
        % compile symbolic expression related to the systems
        obj = compile(obj, export_path, varargin);
        
        % check if (name) is a valid variable
        [flag, var_group] = validateVarName(obj, name)
    end
    
    
    methods
        function obj = DynamicalSystem(name, type)
            % The class construction function
            %
            % Parameters:
            % name: the name of the system @type char
            % type: the type of the system @type char
            
            
            
            assert(isvarname(name),...
                'The name of the system must be a valid variable name vector.');            
            obj.Name = name;
            
                    
            obj.Type = DynamicalSystem.validateSystemType(type);
            
            if strcmp(obj.Type,'FirstOrder')
                obj.States = struct('x',[],'dx',[]);
            elseif strcmp(obj.Type, 'SecondOrder')
                obj.States = struct('x',[],'dx',[],'ddx',[]);
            end
            obj.Inputs = struct();
            obj.Params = struct();
            
            obj.Gmap = struct();
            obj.Gvec = struct();
            obj.Fvec = cell(0);
            obj.Mmat = [];
            
            obj.HolonomicConstraints = struct();
            obj.UnilateralConstraints = struct();
        end
        
        
        
        
    end
    
    methods (Static, Access=private)
        
        function v_type = validateSystemType(type)
            % validate if it is valid system type
            
            v_type = validatestring(type,{'FirstOrder','SecondOrder'});
        end
        
    end
    
    
end

