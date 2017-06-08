classdef Display < handle
    % Creates a figure depicting a model
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
    
    properties (Access = protected)
        model
    end
    
    properties (Access = protected)
        items
    end
    
    properties (GetAccess = public, SetAccess = protected)
        ax
    end
    
    methods
        function obj = Display(model, varargin)
            f = figure;
            obj.ax = axes(f);
            obj.model = model;
            
            p = inputParser;
            addParameter(p, 'UseExported', false);
            addParameter(p, 'ExportPath', '');
            addParameter(p, 'SkipExporting', false);
            parse(p, varargin{:});
            
            obj.ax.DataAspectRatio = [1 1 1];
            
            hold(obj.ax, 'on');
            
            obj.items = containers.Map;
            
            for i = 7:length(obj.model.Joints)
                name = ['Joint_', obj.model.Joints(i).Name];
                obj.items(name) = frost.Animator.JointSphere(obj.ax, model, obj.model.Joints(i), name, varargin{:});
            end
            
            for i = 1:length(obj.model.Links)
                name = ['Link_', obj.model.Links(i).Name];
                obj.items(name) = frost.Animator.LinkSphere(obj.ax, model, obj.model.Links(i), name, varargin{:});
            end
            
            for i = 7:length(obj.model.Joints)
                parentName = obj.model.Joints(i).Parent;
                childName = obj.model.Joints(i).Child;
                name = [parentName, '_to_', obj.model.Joints(i).Name];
                obj.items(name) = frost.Animator.Lines(obj.ax, model, obj.model.Links(obj.model.getLinkIndices(parentName)), obj.model.Joints(i), name, varargin{:});
                
                name = [obj.model.Joints(i).Name, '_to_', childName];
                obj.items(name) = frost.Animator.Lines(obj.ax, model, obj.model.Links(obj.model.getLinkIndices(childName)), obj.model.Joints(i), name, varargin{:});
            end
            
            obj.update(zeros(length(obj.model.States.x), 1));
        end
        
        function update(obj, x)
            valueSet = obj.items.values();
            for i = 1:length(valueSet)
                valueSet{i}.update(x);
            end
        end
        
        function addItem(obj, item)
            name = item.name;
            obj.items(name) = item;
        end
        
        function item = removeItem(obj, name)
            item = obj.items(name);
            obj.items.remove(name);
        end
    end
end
