classdef ResetMap
    % ResetMap defines properties and functions related to a
    % discrete transition of the hybrid dynamical system
    % 
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
    
    %% Public properties
    properties (Access = public)
    end
    
    
    %% Protected properties
    properties (SetAccess=protected, GetAccess=public)
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        name
        
        % the reset map options
        %
        % Required fields for resetmap_options:
        %  apply_rigid_impact: indicates there is a rigid impact 
        %  @type logical @default false
        %  relabel_coordinates: indicates whether swap the stant/non-stance legs
        %  @type logical @default false
        %
        % @type struct
        options
       
        
       
        
        
        
        
        
        
        
    end
    
    %% Public methods
    methods
        
        function obj = ResetMap(name, varargin)
            % the default calss constructor
            %
            % Parameters:
            % name: the name of the discrete map @type char
            %
            % Return values:
            % obj: the class object
            
            % call the superclass constructor
            obj.name = name;
            
            % initialize the default options
            obj.options = struct(...
                'apply_rigid_impact',false,...
                'relabel_coordinates',false);
            
            obj.options = set_options(obj.options, varargin{:});
        end
        
        
            
           
        
    end
        
    
end

