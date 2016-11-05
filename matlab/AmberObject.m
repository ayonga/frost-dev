classdef AmberObject
    % AmberObject is a base class for objects that have 'name' (ID) and
    % 'options'.
    %
    %
    % @author Ayonga Hereid @date 2016-09-26
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties (SetAccess=protected, GetAccess=public)
        % This is the name of the object that gives the object an universal
        % identification
        %
        % @type char @default ''
        name = '';
        
        
        % This provides a data structure for available options of the
        % object. Different child class should have their own set of
        % options.
        %
        % @type struct
        options
        
    end
    
    methods
        
        function obj = Amber(name)
            % Constructor function
            %
            % Parameters:
            %  name: the name of the object @type char
            if nargin > 0
                obj.name = name;
            end
        end
        
        function obj = setOptions(obj, varargin)
            % parse input options and set the corresponding option values
            % in the object option fields
            %
            % Parameters:
            %  varargin: optional input arguments
            %
            % Return values:
            %  new_options: newly parsed options from the inputs @type
            %  struct
            
            % if use cell pairs ({'field','value', ...})
            if nargin == 2 && iscell(varargin{1})
                input_cell_arg = varargin{1};
                opts_in = struct(input_cell_arg{:});
            else % if use input pairs ('field','value',....)   
                warning('Unmatched options will be ignored.\n');
                optionList = fields(obj.options);                
                p = inputParser;
                for i = 1:numel(optionList)
                    new_param = optionList{i};
                    addParameter(p, new_param, obj.options.(new_param));
                end
                parse(p,varargin{:});
                opts_in = p.Results;
            end
            
            
            obj.options = struct_overlay(obj.options,opts_in,{'AllowNew',true});
        end
            
        
    end
    
end