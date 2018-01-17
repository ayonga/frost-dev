function c_str = getTwists(obj, p)
    % Returns the symbolic representation of the body jacobians of
    % coordinate frames
    %
    % Each coordiante
    % 
    %
    % Parameters:
    % p: the offset of the point from the origin of the frame 
    % @type matrix
    %
    % Return values:
    % c_str: a cell array of twist information @type cell
    
    n_frame = length(obj);
    n_pos   = n_frame;
    if nargin < 2
        p = zeros(n_frame,3);
    else
        if isempty(p)
            p = zeros(n_frame,3);
        else
            if n_frame == 1 % single frame
                validateattributes(p,{'double'},{'2d','real','size',[NaN,3]},...
                    'getCartesianPosition','offset',3);
                % update the number of position
                n_pos = size(p,1);
            else % multiple frames
                validateattributes(p,{'double'},{'2d','real','size',[n_frame,3]},...
                    'getCartesianPosition','offset',3);
            end
        end
    end
  
        
    c_str = cell(1,n_pos);
    
    
    for i=1:n_pos
        if n_frame > 1 % multiple frames
            c_str{i}.gst0 = obj(i).gst0*CoordinateFrame.RPToHomogeneous(eye(3), p(i,:));
            ref = obj(i);
        else  % single frame
            c_str{i}.gst0 = obj.gst0*CoordinateFrame.RPToHomogeneous(eye(3), p(i,:));
            ref = obj;
        end
            
        
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