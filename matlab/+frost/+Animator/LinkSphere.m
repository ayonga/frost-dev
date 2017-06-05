classdef LinkSphere < frost.Animator.Sphere
    % Sphere depicting center of mass of a rigid link for
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
    
    methods
        function obj = LinkSphere(ax, model, linkFrame, name, varargin)
            obj = obj@frost.Animator.Sphere(ax, model, linkFrame, name, varargin{:});
            
            obj.radius = 0.03;
            obj.surface.FaceColor = 'blue';
        end
    end
end
