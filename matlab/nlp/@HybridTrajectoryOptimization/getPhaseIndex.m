function phase_idx = getPhaseIndex(obj, varargin)
    % Returns the index of a particular phase (TrajectoryOptimization
    % object) associated with the input argument.
    %
    % The input argument can be the node name/index or the edge endnodes.
    % If there is only one input argument, then it will returns the
    % associated phase index of the node; if there are two input argument,
    % then it will returns the associated phase index of the edge.
    % 
    % For example:
    %
    % idx = getPhaseIndex(obj, nodeID) 
    %
    % will return the continuous phase;
    %
    % idx = getPhaseIndex(obj, s, t)
    %
    % will return the discrete phase.
    % 
    %
    
    narginchk(2,3);
    switch nargin 
        case 2 % node
            node_id = findnode(obj.Gamma, varargin{1});
            if node_id==0
                warning('There is no such node exist!');
                phase_idx = [];
            else
                phase_idx = node_id*2-1;
            end
        case 3 % edge
            edge_id = findedge(obj.Gamma, varargin{1}, varargin{2});
            if edge_id==0
                warning('There is no such edge exist!');
                phase_idx = [];
            else
                phase_idx = edge_id*2;
            end
    end
    
    
    
    
    
    

end