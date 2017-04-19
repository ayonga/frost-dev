function [varargout] = getBodyJacobian(obj, varargin)
    % Returns the symbolic representation of the body jacobians of
    % coordinate frames
    %
    % Each coordiante
    % 
    %
    % Parameters:
    % varargin: a cell array of coordinate frames @type cell
    % 
    % Return values:
    % pos: the 6xnDof Jacobian matrix of a rigid coordinate frame @type SymExpression
    %
    %
    % @note Syntax for ont point
    %  
    % >> jac = getBodyJacobian(obj,{'Link1',[0,0,0.1]})
    %
    % @note Syntax for multiple points
    % 
    % >> [jac1,jac2] = getBodyJacobian(obj,{'Link1',[0,0,0.1]},{'Link2',[0.2,0,0.1]})
    
    
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
            c_str{i}.ChainIndices = frame.ChainIndices;
        end
        
        jac = eval_math_fun('ComputeBodyJacobians',[c_str, {obj.numState}]);
        
        varargout = cell(1,n_pos);
        for i=1:n_pos
            varargout{i} = jac(i,:);
        end
    else
        varargout = {};
    end
end