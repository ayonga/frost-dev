classdef Sphere < frost.Animator.DisplayItem
    % Sphere object for frost.Animator.Display
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
        frame
        surface
    end
    
    properties (Access = public)
        radius
    end
    
    properties (GetAccess = public, SetAccess = private)
        func_center
    end
    
    methods
        function obj = Sphere(ax, model, frame, name, varargin)
            obj = obj@frost.Animator.DisplayItem(ax, model, name);
            obj.frame = frame;
            obj.radius = 0.02;
            
            p = inputParser;
            addParameter(p, 'UseExported', false);
            addParameter(p, 'ExportPath', '');
            addParameter(p, 'SkipExporting', false);
            parse(p, varargin{:});
            
            if p.Results.UseExported
                if p.Results.SkipExporting == false
                    expr = getCartesianPosition(obj.model, obj.frame).';
                    symFunc = SymFunction([obj.name, '_sphere_center'], expr, {model.States.x});
                    symFunc.export(p.Results.ExportPath);
                end

                obj.func_center = str2func([obj.name, '_sphere_center']);
            else
                expr = getCartesianPosition(obj.model, obj.frame).';
                
                obj.func_center = @(x) double(subs(expr, obj.model.States.x, x));
            end
            
            x0 = zeros(length(obj.model.States.x), 1);
            position = obj.func_center(x0);
            
            [xs, ys, zs] = sphere(10);
            obj.surface = surf(obj.ax, xs*obj.radius + position(1),...
                ys*obj.radius + position(2),...
                zs*obj.radius + position(3),...
                'FaceColor', 'black', 'EdgeColor', 'none');
        end
        
        function obj = update(obj, x)
            position = obj.func_center(x);
            
            [xs, ys, zs] = sphere(10);
            obj.surface.XData = xs*obj.radius + position(1);
            obj.surface.YData = ys*obj.radius + position(2);
            obj.surface.ZData = zs*obj.radius + position(3);
        end
        
        function obj = delete(obj)
            delete(obj.surface);
        end
    end
end
