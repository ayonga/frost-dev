function c_str = getTwists(obj, p)
    % Returns the symbolic representation of the body jacobians of
    % coordinate frames
    %
    % Each coordiante
    % 
    %
    % Parameters:
    % frame: the list of coordinate frame of the point 
    % @type cell
    % p: the offset of the point from the origin of the frame 
    % @type matrix
    %
    % Return values:
    % c_str: a cell array of twist information @type cell
    
    n_pos = length(obj);
    if nargin < 2
        p = zeros(n_pos,3);
    else
        if isempty(p)
            p = zeros(n_pos,3);
        else
            validateattributes(p,{'double'},{'2d','real','size',[n_pos,3]},...
                'getCartesianPosition','offset',3);
        end
    end
  
        
    c_str = cell(1,n_pos);
    
    
    for i=1:n_pos
        c_str{i}.gst0 = obj(i).gst0*CoordinateFrame.RPToHomogeneous(eye(3), p(i,:));
        ref = obj(i).Reference;
        while ~isprop(ref,'TwistPairs')
            ref = ref.Reference;
            if isempty(ref)
                error('The coordinate system is not fully defined.');
            end
        end
        
        c_str{i}.TwistPairs = ref.TwistPairs;
        c_str{i}.ChainIndices = ref.ChainIndices;
    end
    
end