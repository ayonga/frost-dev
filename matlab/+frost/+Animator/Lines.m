classdef Lines < frost.Animator.DisplayItem
    % Line object for frost.Animator.Display
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
        frame1
        frame2
        line
    end
    
    properties (GetAccess = public, SetAccess = private)
        func_p1
        func_p2
    end
    
    methods
        function obj = Lines(ax, model, frame1, frame2, name, varargin)
            obj = obj@frost.Animator.DisplayItem(ax, model, name);
            obj.frame1 = frame1;
            obj.frame2 = frame2;
            
            p = inputParser;
            addParameter(p, 'UseExported', false);
            addParameter(p, 'ExportPath', '');
            addParameter(p, 'SkipExporting', false);
            parse(p, varargin{:});
            
            if p.Results.UseExported
                if p.Results.SkipExporting == false
                    expr = getCartesianPosition(obj.model, obj.frame1).';
                    symFunc = SymFunction([obj.name, '_p1'], expr, {model.States.x});
                    symFunc.export(p.Results.ExportPath);
            
                    expr = getCartesianPosition(obj.model, obj.frame2).';
                    symFunc = SymFunction([obj.name, '_p2'], expr, {model.States.x});
                    symFunc.export(p.Results.ExportPath);
                end

                obj.func_p1 = str2func([obj.name, '_p1']);
                obj.func_p2 = str2func([obj.name, '_p2']);
            else
                expr1 = getCartesianPosition(obj.model, obj.frame1).';
                expr2 = getCartesianPosition(obj.model, obj.frame2).';
                
                obj.func_p1 = @(x) double(subs(expr1, obj.model.States.x, x));
                obj.func_p2 = @(x) double(subs(expr2, obj.model.States.x, x));
            end
            
            x0 = zeros(length(obj.model.States.x), 1);
            p1 = obj.func_p1(x0);
            p2 = obj.func_p2(x0);
            
            obj.line = plot3(obj.ax, [p1(1), p2(1)], [p1(2), p2(2)], [p1(3), p2(3)], 'k');
        end
        
        function obj = update(obj, x)
            p1 = obj.func_p1(x);
            p2 = obj.func_p2(x);
            
            obj.line.XData = [p1(1), p2(1)];
            obj.line.YData = [p1(2), p2(2)];
            obj.line.ZData = [p1(3), p2(3)];
        end
        
        function obj = delete(obj)
            delete(obj.surface);
        end
    end
end
