function pos = getCartesianPosition(obj, varargin)
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
    n_pos = nargin - 1;
    
    valid_link_name = {obj.Links.name};
    % validate the input arguments
    for i=1:n_pos
        
        [link_name, offset] = deal(varargin{i}{:});
        % validate parent link name (case insensitive)
        varargin{i}{1} = str2mathstr(validatestring(link_name,valid_link_name));
        
        
        % validate if it is a numeric 3-D vector
        validateattributes(offset, {'numeric'},{'vector','numel',3});
        
    end
    
    pos = eval_math_fun('ComputeCartesianPositions',[varargin, {obj.SymTwists}]);
    
end