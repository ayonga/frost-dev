classdef EllipsoidCoMVert < frost.Animator.DisplayItem
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
        function obj = EllipsoidCoMVert(ax, model, frame, name, varargin)
            obj = obj@frost.Animator.DisplayItem(ax, model, name);
            obj.frame = frame;
            obj.radius = 0.06;
            
            p = inputParser;
            addParameter(p, 'UseExported', false);
            addParameter(p, 'ExportPath', '');
            addParameter(p, 'SkipExporting', false);
            parse(p, varargin{:});
%             
%             if p.Results.UseExported
%                 if p.Results.SkipExporting == false
%                     expr = getCartesianPosition(obj.model, obj.frame).';
%                     symFunc = SymFunction([obj.name, '_sphere_center'], expr, {model.States.x});
%                     symFunc.export(p.Results.ExportPath);
%                 end
% 
%                 obj.func_center = str2func([obj.name, '_sphere_center']);
%             else
                expr = obj.model.getComPosition().';
                
                obj.func_center = @(x) double(subs(expr, obj.model.States.x, x));
%             end
            
            x0 = zeros(length(obj.model.States.x), 1);
            position = obj.func_center(x0);
            
      
            
            [x, y, z] = ellipsoid(position(1),position(2),position(3),0.005,0.005,0.06,20);
            

           obj.surface= surf(x, y, z,'FaceColor', 'blue', 'EdgeColor', 'none');
            
            

        

            
            
            
axis equal
            
            
        end
        
        function obj = update(obj, x)
            position = obj.func_center(x);
            
            
            [x, y, z] = ellipsoid(position(1),position(2),position(3),0.005,0.005,0.06,20);
             obj.surface.XData = x;
            obj.surface.YData = y;
            obj.surface.ZData = z;
            
            
            
        end
        
        function obj = delete(obj)
            delete(obj.surface);
        end
    end
end
