classdef Domain
    % Domain defines an admissible continuous domain (or phase) in the
    % hybrid system model. The admissibility conditions are determined by
    % the kinematic constraints defined on the domain.
    % 
    % Contraints are typically given as kinematic constraints, such as
    % holonomic constraints and unilateral constraints, of the rigid body
    % model.
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
    
    
    
    %% Protected properties
    properties (SetAccess=private, GetAccess=public)
        
        %% basic properties
        
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char 
        Name
        
        
        
        %% holonomic constraints
        
        % A group of holonomic kinematic constraints
        %
        % @type KinematicGroup
        HolonomicConstr
        
        
        %% unilateral constraints 
        % A table of all unilateral constraints
        %
        % @type table
        UnilateralConstr
        
        
        
        
        
    
       
        %% actuation
        
        % a map for robot actuation on the current domain
        %
        % @type matrix
        ActuationMap
        
        
        
    end
    
    
    
    %% Public methods
    methods
        
        function obj = Domain(name)
            % the calss constructor for Domain class
            %
            % Parameters:
            % name: the name of the domain @type char
            
            
            if ischar(name)
                obj.Name = name;                
            else
                error('The domain name must be a string.');
            end
            
            
            
            obj.HolonomicConstr  = KinematicGroup('Name', name, 'Prefix', 'hol');
            
            obj.UnilateralConstr = cell2table(cell(0,5),'VariableNames',...
                {'Name','Type','WrenchCondition','KinObject','KinName'});
            
        end
        
        
        
        
        
    end % public methods
        
    
    
    
    %% methods defined in external files
    methods
        obj = addContact(obj, contacts);
        
        obj = addHolonomicConstraint(obj, kins);
        
        obj = addUnilateralConstraint(obj, kins);
        
        obj = removeContact(obj, contacts);
        
        obj = removeHolonomicConstraint(obj, kins);
        
        obj = removeUnilateralConstraint(obj, kins);
        
        obj = setAcutation(obj, model, actuated_joints);
        
        obj = compile(obj, model, varargin);
                
        obj = export(obj, export_path, do_build);
        
        [Fe] = calcConstraintForces(obj, varargin);
                
        value = calcUnilateralCondition(obj, cond, model, qe, dqe, u);
        
        [vfc, gfc] = calcVectorFields(obj, model, qe, dqe, De, He);
    end 
    
    
    
    
    
end % classdef

