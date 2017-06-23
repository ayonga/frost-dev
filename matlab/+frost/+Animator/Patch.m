classdef Patch < frost.Animator.DisplayItem
    % Patch depicting a polyhydron surface for frost.Animator.Display
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
        faces
        patch
    end
    
    
    properties (GetAccess = public, SetAccess = private)
        func
    end
    
    methods
        function obj = Patch(ax, model, frame, offset, faces, name, varargin)
            obj = obj@frost.Animator.DisplayItem(ax, model, name);
            
            obj.frame = frame;
            obj.offset = offset;
            obj.faces = faces;
            
            
            
            p = inputParser;
            addParameter(p, 'UseExported', false);
            addParameter(p, 'ExportPath', '');
            addParameter(p, 'SkipExporting', false);
            parse(p, varargin{:});
            
            if p.Results.UseExported
                if p.Results.SkipExporting == false
                    expr = obj.getSymbolicExpr();
                    symFunc = SymFunction([obj.name, '_patch'], expr, {model.States.x});
                    symFunc.export(p.Results.ExportPath);
                end

                obj.func = str2func([obj.name, '_patch']);
            else
                expr = obj.getSymbolicExpr();
                
                obj.func = @(x) double(subs(expr, obj.model.States.x, x));
            end
            x0 = zeros(length(obj.model.States.x), 1);
            v = obj.func(x0);
            
            
            obj.patch = patch(obj.ax, 'Faces',obj.faces,'Vertices',v,...
                'FaceColor', 'blue', 'EdgeColor', 'white');
        end
        
        function obj = update(obj, x)
            v = obj.func(x);
            obj.patch.Vertices = v;
        end
        
        function obj = delete(obj)
            delete(obj.patch);
            
        end
    end
    
    methods (Access=private)
        function expr = getSymbolicExpr(obj)
            % Obtain the symbolic expression for the forward kinematics of
            % cylinder surface data points
            
            
            expr = obj.model.getCartesianPosition(obj.frame, obj.offset);
        end
        
        
    end
end
