function [varargout] = getEulerAngles(obj, varargin)
    % Returns the symbolic representation of the Euler angles of a
    % rigid link.
    %
    % Parameters:
    % varargin: the name of the rigid links @type char
    % 
    % Return values:    
    %  ang: the 3-dimensional Euler angles (roll,pitch,yaw) vector of the
    %  CoM of the system @type SymExpression
    %
    %
    % @note Syntax for ont link
    %  
    % >> getEulerAngles(obj,'Link1')
    %
    % @note Syntax for multiple links
    % 
    % >> getEulerAngles(obj,{'Link1','Link2'})
    
    
    % the number of points (one less than the nargin)
    n_pos = numel(varargin);
    if n_pos>0
        c_str = cell(1,n_pos);
        
        
        for i=1:n_pos
            c_str{i}.gst0 = varargin{i}.gst0;
            frame = varargin{i}.Reference;
            while isempty(frame.TwistPairs)
                frame = frame.Reference;
                if isempty(frame)
                    error('The coordinate system is not fully defined.');
                end
            end
            
            c_str{i}.TwistPairs = frame.TwistPairs;
        end
        
        ang = eval_math_fun('ComputeEulerAngles',c_str);
        
        varargout = cell(1,n_pos);
        for i=1:n_pos
            varargout{i} = ang(i,:);
        end
    else
        varargout = {};
    end
    
end