function [varargout] = getSpatialJacobian(obj, varargin)
    % Returns the symbolic representation of the spatial jacobian of the point
    % that is rigidly attached to the link with a given offset.
    %
    % Parameters:
    % varargin: the pairs of {parentlink,offset} of specified points 
    % @type cell
    % 
    % Return values:
    % pos: the 6xnDof Jacobian matrix of a rigid point @type SymExpression
    %
    %
    % @note Syntax for ont point
    %  
    % >> jac = getSpatialJacobian(obj,{'Link1',[0,0,0.1]})
    %
    % @note Syntax for multiple points
    % 
    % >> [jac1,jac2] = getSpatialJacobian(obj,{'Link1',[0,0,0.1]},{'Link2',[0.2,0,0.1]})
    
    
    % the number of points (one less than the nargin)
    n_pos = numel(varargin);
    if n_pos > 0
        valid_link_name = {obj.Links.name};
        % validate the input arguments
        for i=1:n_pos
            
            [link_name, offset] = deal(varargin{i}{:});
            % validate parent link name (case insensitive)
            varargin{i}{1} = str2mathstr(validatestring(link_name,valid_link_name));
            
            
            % validate if it is a numeric 3-D vector
            validateattributes(offset, {'numeric'},{'vector','numel',3});
            
        end
        
        jac = eval_math_fun('ComputeSpatialJacobians',[varargin, {obj.SymTwists}]);
        
        varargout = cell(1,n_pos);
        for i=1:n_pos
            varargout{i} = jac(i,:);
        end
    else
        varargout = {};
    end
end