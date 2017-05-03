function [varargout] = getCartesianPosition(obj, varargin)
    % Returns the symbolic representation of the Cartesian positions of a
    % rigid point specified by a list of (parentlink,offset) pairs
    %
    % Parameters:
    % varargin: the pairs of {parentlink,offset} of specified points 
    % @type cell
    % 
    % Return values:
    % pos: the 3-Dimensional SO(3) position vectors of the fixed rigid
    % points @type SymExpression
    %
    %
    % @note Syntax for ont point
    %  
    % >> getCartesianPosition(obj,{'Link1',[0,0,0.1]})
    %
    % @note Syntax for multiple points
    % 
    % >> getCartesianPosition(obj,{'Link1',[0,0,0.1]},{'Link2',[0.2,0,0.1]})
    
    
    % the number of points (one less than the nargin)
    n_pos = numel(varargin);
    if n_pos > 0
        
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
        
        pos = eval_math_fun('ComputeCartesianPositions',c_str);
        
        varargout = cell(1,n_pos);
        for i=1:n_pos
            varargout{i} = pos(i,:);
        end
    else
        varargout = {};
    end
    
end