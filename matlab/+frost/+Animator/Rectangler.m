classdef Rectangler < frost.Animator.Patch
    % Patch depicting a 3d rectangler for frost.Animator.Display
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
    
   
    methods
        function obj = Rectangler(ax, model, frame, p1, p2, name, varargin)
            faces = [...
                1,2,3,4;
                1,2,6,5;
                5,6,7,8;
                7,8,4,3;
                1,5,8,4;
                2,6,7,3];
            
            x1 = p1(1); y1 = p1(2); z1 = p1(3);
            x2 = p2(1); y2 = p2(2); z2 = p2(3);
            
            offset = [...
                x1, y1, z1;
                x1, y1, z2;
                x1, y2, z2;
                x1, y2, z1;
                x2, y1, z1;
                x2, y1, z2;
                x2, y2, z2;
                x2, y2, z1];
            
            
            
            obj = obj@frost.Animator.Patch(ax, model, frame, offset, faces, name, varargin{:});
            
            
            
            
        end
        
    end
end
