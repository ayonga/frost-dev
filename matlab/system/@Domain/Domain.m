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
        
        % a cell array of holonomic constraints given as objects of
        % Kinematics classes
        %
        % @type KinematicGroup
        HolonomicConstr
        
        
        %% unilateral constraints 
        % forces, distance
        %
        % @type KinematicGroup
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
            
            
            
            obj.HolonomicConstr = KinematicGroup('Name',['hol',name]);
            obj.UnilateralConstr = KinematicGroup('Name',['uni',name]);
%             obj.UnilateralConstr = cell2table(cell(0,6),'VariableNames',...
%                 {'Name','Type','WrenchCondition','WrenchIndices','KinObject','KinFunction'});
            
        end
        
        
        
        
        
    end % public methods
        
    %% Methods defined seperate files
    methods
        
        obj = setAcutation(obj, model, actuated_joints);
        
        
      
        
        obj = compile(obj, model, varargin);
                
        obj = export(obj, export_path, do_build);
        
        
    end
    
    
    
    
    
    
    
end % classdef

