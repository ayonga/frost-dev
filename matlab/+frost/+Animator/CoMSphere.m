classdef CoMSphere < frost.Animator.Sphere
    % Sphere depicting joints and axis of rotation for
    % frost.Animator.Display
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
        line
    end
    
    properties (Access = public)
        length
    end
    
    properties (GetAccess = public, SetAccess = private)
        func_axis
    end
    
    methods
        function obj = CoMSphere(ax, model, varargin)
            
            name = ['p_com_',model.Name];
            obj = obj@frost.Animator.Sphere(ax, model, model.Joints(1), name, varargin{:});

            obj.radius = 0.1;
            obj.surface.FaceColor = 'green';
            
            
            p = inputParser;
            addParameter(p, 'UseExported', false);
            addParameter(p, 'ExportPath', '');
            addParameter(p, 'SkipExporting', false);
            parse(p, varargin{:});
            
            
            if p.Results.UseExported
                if p.Results.SkipExporting == false
                    expr = model.getComPosition().';
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
                'FaceColor', obj.surface.FaceColor, 'EdgeColor', 'black');
        end
        
        
    end
end
