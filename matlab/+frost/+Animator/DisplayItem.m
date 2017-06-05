classdef (Abstract) DisplayItem < handle
    % Abstract class for items in frost.Animator.Display
    % 
    % @author omar @date 2017-06-01
    % 
    % Copyright (c) 2017, UMICH Biped Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/BSD-3-Clause
    
    properties (SetAccess = private, GetAccess = protected)
        ax
        model
    end
    
    properties (SetAccess = private, GetAccess = public)
        name
    end
    
    methods
        function obj = DisplayItem(ax, model, name)
            obj.ax = ax;
            obj.model = model;
            obj.name = name;
        end
    end
    
    methods (Abstract)
        update(obj, x);
    end
end
