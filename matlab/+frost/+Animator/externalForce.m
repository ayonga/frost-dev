classdef externalForce < frost.Animator.DisplayItem
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
        patch
    end
    
    properties (Access = public)
        radius
    end
    
    properties (GetAccess = public, SetAccess = private)
        func_center
        f
    end
    
    methods
        function obj = externalForce(ax, model, frame, name, varargin)
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
Torso=CoordinateFrame(...
'Name','TorsoTop',...
'Reference', model.Links(12).Reference,...
'Offset', [-0.1,0,0.5],...
'R', eye(3));
                expr = obj.model.getCartesianPosition(Torso).';
                f=obj.model.Inputs.External.torsoForce;
                
                obj.func_center = @(x) double(subs(expr, obj.model.States.x, x));
                obj.f=@(ft) double(subs(f,obj.model.Inputs.External.torsoForce,ft));
%             end
            
            x0 = zeros(length(obj.model.States.x), 1);
            f0=0;
            tP = obj.func_center(x0);
            uT=obj.f(f0)/9.81;
                        
           if uT== 0
               X=zeros(3,1);
                Y=zeros(3,1);
                Z=zeros(3,1);
           else
               
           X=[tP(1), tP(1)*uT, (tP(1)*uT+tP(1))/2];
           Y=[tP(2), tP(2)*uT, (tP(2)*uT+tP(2))/2];
           Z=[tP(3), tP(3), tP(2)*uT];
           end
            
           obj.patch=patch(X,Y,Z,0);
            
                              
            
            
axis equal
            
            
        end
        
        function obj = update(obj, x,ft)
            tP = obj.func_center(x);
            uT=obj.f(ft)/15;
            if uT==0
                X=zeros(1,3);
                Y=zeros(1,3);
                Z=zeros(1,3);
            else
               X=[tP(1), tP(1)*uT, (tP(1)*uT+tP(1))/2];
           Y=[tP(2), tP(2)*uT, (tP(2)*uT+tP(2))/2];
           Z=[tP(3), tP(3), tP(2)*uT];
%            Y=zeros(1,3);
%            X=[3,3,3];
%             Z=[2, 2, 2];
            end
            
            obj.patch.Vertices=[X;Y;Z];
            
              
            
        end
        
        function obj = delete(obj)
            delete(obj.surface);
        end
    end
end
