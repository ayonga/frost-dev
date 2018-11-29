classdef Cylinder < frost.Animator.DisplayItem
    % Cylinder depicting a cylinder surface between two points for
    % frost.Animator.Display
    % 
    % @author ayonga @date 2017-06-20
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
        offset
        surface
    end
    
    properties (Access = public)
        radius
        n
    end
    
    properties (GetAccess = public, SetAccess = private)
        func
    end
    
    methods
        function obj = Cylinder(ax, model, frame, offset, name, varargin)
            obj = obj@frost.Animator.DisplayItem(ax, model, name);
            obj.radius = 0.015;
            obj.n = 20;
            obj.frame = frame;
            obj.offset = offset;
            
            p = inputParser;
            addParameter(p, 'UseExported', false);
            addParameter(p, 'ExportPath', '');
            addParameter(p, 'SkipExporting', false);
            parse(p, varargin{:});
            
            if p.Results.UseExported
                if p.Results.SkipExporting == false
                    expr = obj.getSymbolicExpr();
                    symFunc = SymFunction([obj.name, '_bar'], expr, {model.States.x});
                    symFunc.export(p.Results.ExportPath);
                end

                obj.func = str2func([obj.name, '_bar']);
            else
                expr = obj.getSymbolicExpr();
                
                obj.func = @(x) double(subs(expr, obj.model.States.x, x));
            end
            x0 = zeros(length(obj.model.States.x), 1);
            xyz = obj.func(x0);
            x = xyz(:,[1,4])';
            y = xyz(:,[2,5])';
            z = xyz(:,[3,6])';
            
            
            obj.surface = surface(obj.ax, x, y, z,...
                'FaceColor', 'blue', 'EdgeColor', 'none');
        end
        
        function obj = update(obj, x)
            xyz = obj.func(x);
            x = xyz(:,[1,4])';
            y = xyz(:,[2,5])';
            z = xyz(:,[3,6])';
            obj.surface.XData = x;
            obj.surface.YData = y;
            obj.surface.ZData = z;
        end
        
        function obj = updateFaceColor(obj, color)
            obj.surface.FaceColor = color;
        end
        
        function obj = delete(obj)
            delete(obj.surface);
            
        end
    end
    
    methods (Access=private)
        function expr = getSymbolicExpr(obj)
            % Obtain the symbolic expression for the forward kinematics of
            % cylinder surface data points
            
            [p1,p2] = obj.cylinder2P();
            
            pos_i = obj.model.getCartesianPosition(obj.frame, p1);
            pos_o = obj.model.getCartesianPosition(obj.frame, p2);
            
            
            expr = [pos_i,pos_o];
        end
        
        function [p1,p2] = cylinder2P(obj)
            
            % The parametric surface will consist of a series of N-sided
            % polygons with successive radios given by R.
            % Z increases in equal sized steps from 0 to 1.
            
            % Set up an array of angles for the polygon.
            N = obj.n;
            R = obj.radius;
            theta = linspace(0,2*pi,N);
            r1 = [0,0,0];
            r2 = obj.offset;
            
            
            m = 2;
            
            
            
            v=(r2-r1)/sqrt((r2-r1)*(r2-r1)');    %Normalized vector;
            %cylinder axis described by: r(t)=r1+v*t for 0<t<1
            R2=rand(1,3);              %linear independent vector (of v)
            x2=v-R2/(R2*v');    %orthogonal vector to v
            x2=x2/sqrt(x2*x2');     %orthonormal vector to v
            x3=cross(v,x2);     %vector orthonormal to v and x2
            x3=x3/sqrt(x3*x3');
            
            r1x=r1(1);r1y=r1(2);r1z=r1(3);
            r2x=r2(1);r2y=r2(2);r2z=r2(3);
            % vx=v(1);vy=v(2);vz=v(3);
            x2x=x2(1);x2y=x2(2);x2z=x2(3);
            x3x=x3(1);x3y=x3(2);x3z=x3(3);
            
            
            p1 = [r1x+R*cos(theta)*x2x+R*sin(theta)*x3x;
                r1y+R*cos(theta)*x2y+R*sin(theta)*x3y;
                r1z+R*cos(theta)*x2z+R*sin(theta)*x3z]';
            p2 = p1 + repmat([(r2x-r1x),(r2y-r1y),(r2z-r1z)],[N,1]);
        end
    end
end
