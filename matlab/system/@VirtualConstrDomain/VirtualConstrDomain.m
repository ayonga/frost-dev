classdef VirtualConstrDomain < Domain
    % Defines a subclass of continuous domain with virtual constraints.
    %
    % @author ayonga @date 2016-09-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess=private, GetAccess=public)
        
        
        % The parameterized time variable (phase variable)
        %
        % Required fields of PhaseVariable:
        % Type: the type of the parameterized time variable @type char
        % Var: the kinematic object if it is a state-based phase variable
        % @type Kinematics
        % Param: the scaling parameters of the state-based phase variable
        % @type colvec
        % 
        % @type struct
        PhaseVariable
        
        % The desired position-modulating outputs of the domain
        % 
        % @type struct 
        DesPositionOutput
        
        % The desired velocity-modulating outputs of the domain
        % 
        % @type struct
        DesVelocityOutput
        
        % The actual position-modulating outputs of the domain
        %
        % The position-modulating outputs are (vector) relative degree two
        % by definition.
        % 
        % @type KinematicGroup 
        ActPositionOutput
        
        % The actual velocity-modulating output of the domain
        %
        % The velocity-modulating outputs are relative degree one
        % by definition.
        % 
        % @type Kinematics
        ActVelocityOutput
        
        % The parameter set of the domain
        %
        % Optional fields of Param:
        % p: the scaling parameters of the phase variable @type double
        % v: the parameters of the desired velocity output @type double
        % a: the parameters of the desired position outputs @type matrix
        %
        % @type struct
        Param
        
        
    end % properties
    
    
    methods
        function obj = VirtualConstrDomain(name, varargin)
            % The class constructor function
            
            
            obj = obj@Domain(name,varargin{:});
            
            % initialize the default (TimeBased) phase variable 
            obj.PhaseVariable = struct(...
                'Type', 'TimeBased',...
                'Var', []);
            
            obj.Param = struct(...
                'p',[],...
                'v',[],...
                'a',[]);
        end
        
        
        
        
    end % methods
    
    %% methods defined in external files
    methods
        obj = setPhaseVariable(obj, type, var);
        
        obj = setVelocityOutput(obj, act, des);
        
        obj = addPositionOutput(obj, act, des);
        
        obj = removePositionOutput(obj, act);
        
        obj = changeDesiredOutputType(obj, varargin);
        
        obj = setParam(obj, varargin);
        
        
        
        y_act = calcActualOutputs(obj, qe, dqe);
        
        [y_des, extra] = calcDesiredOutputs(obj, t, qe, dqe);
        
        obj = compile(obj, model, varargin);
        
        status = export(obj, export_path, do_build);
        
        [indices] = getPositionOutputIndex(obj, output_name);
    end
    
    %% static methods
    methods (Static)
        [expr, n_param] = getDesOutputExpr(type);
        
       
    end % static methods
end % classdef
