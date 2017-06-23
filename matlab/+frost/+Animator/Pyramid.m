classdef Pyramid < frost.Animator.Patch
    % Patch depicting a 3d Pyramid for frost.Animator.Display
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
        function obj = Pyramid(ax, model, frame, top, base, name, varargin)
            
            
            
            
            
            offset = [top; base];
            n_base = size(base,1);
            bf_s = cumsum(ones(n_base,1)) + 1;
            bf_e = bf_s([2:end, 1]);
            faces = [
                ones(n_base,1), bf_s, bf_e, nan(n_base, n_base-3);
                bf_s'];
            
            
            obj = obj@frost.Animator.Patch(ax, model, frame, offset, faces, name, varargin{:});
            
            
            
            
        end
        
    end
end
