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
    
    properties (Access = public)
        items
    end
    
    properties (GetAccess = public, SetAccess = protected)
        axs
        fig
    end
    
    methods
        function obj = Display(f, model, varargin)
            obj.fig = f;
            obj.axs = axes(f);
            obj.model = model;
            
            p = inputParser;
            addParameter(p, 'UseExported', false);
            addParameter(p, 'ExportPath', '');
            addParameter(p, 'SkipExporting', false);
            parse(p, varargin{:});
            
            obj.axs.DataAspectRatio = [1 1 1];
            
            hold(obj.axs, 'on');
            
            obj.items = containers.Map;
            
            %             for i = 1:length(obj.model.Joints)
            %                 if i > 1 && all(obj.model.Joints(i).Offset == [0,0,0])
            %                     continue; % skip if the joint offset is zero
            %                 end
            %                 name = ['Joint_', obj.model.Joints(i).Name];
            %                 obj.items(name) = frost.Animator.JointSphere(obj.axs, model, obj.model.Joints(i), name, varargin{:});
            %             end
            
            %             for i = 1:length(obj.model.Links)
            %                 name = ['Link_', obj.model.Links(i).Name];
            %                 obj.items(name) = frost.Animator.LinkSphere(obj.axs, model, obj.model.Links(i), name, varargin{:});
            %             end
            
            
            links = {obj.model.Links.Name};
            for i = 1:length(obj.model.Joints)
                parentName = obj.model.Joints(i).Parent;
                % if there is no child link present in the link array of
                % the robot, then skip
                if ~ismember(parentName,links) 
                    continue;
                end
                if i > 1 && all(obj.model.Joints(i).Offset == [0,0,0])
                    continue; % skip if the joint offset is zero
                end
                
                name = ['Link_', parentName, '_to_', obj.model.Joints(i).Name];
                frame = CoordinateFrame('Name',obj.model.Joints(i).Reference.Name,...
                    'Reference',obj.model.Joints(i).Reference,...
                    'Offset',[0,0,0],...
                    'R',[0,0,0]);
                offset = obj.model.Joints(i).Offset;
                obj.items(name) = frost.Animator.Cylinder(obj.axs, model, frame, offset, name, varargin{:});
                
                
                name = ['Joint_', obj.model.Joints(i).Reference.Name];
                if ~isKey(obj.items,name)
                    obj.items(name) = frost.Animator.JointSphere(obj.axs, model, obj.model.Joints(i).Reference, name, varargin{:});
                end
                name = ['Joint_', obj.model.Joints(i).Name];
                if ~isKey(obj.items,name)
                    obj.items(name) = frost.Animator.JointSphere(obj.axs, model, obj.model.Joints(i), name, varargin{:});
                end
                %                 name = [parentName, '_to_', obj.model.Joints(i).Name];
                %                 obj.items(name) = frost.Animator.Lines(obj.axs, model, obj.model.Links(obj.model.getLinkIndices(parentName)), obj.model.Joints(i), name, varargin{:});
                %
                %                 name = [obj.model.Joints(i).Name, '_to_', childName];
                %                 obj.items(name) = frost.Animator.Lines(obj.axs, model, obj.model.Links(obj.model.getLinkIndices(childName)), obj.model.Joints(i), name, varargin{:});
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
            item.delete();
            obj.items.remove(name);
        end
    end
end
