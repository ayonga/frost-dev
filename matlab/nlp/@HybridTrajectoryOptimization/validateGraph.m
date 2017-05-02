function validateGraph(~, plant)
    % validate the directed graph of the hybrid system model
    %
    % @note The hybrid trajectory optimization problem is only able to
    % handle system graph that is cyclic or with single branches.
    
    
    
    % if not simple directed cycle, check if any node whose
    % in-degree or out-degree is more than 1. If true, than the
    % graph consists of branching, hence not a valid graph for
    % trajectory optimization problem
    g = plant.Gamma;
    %     assert(~any(indegree(g) > 1),...
    %         'The following node(s): \n %s \n have more than one predecessors.',...
    %         implode(g.Node.Names(indegree(g)>1),','));
    assert(~any(outdegree(g) > 1),...
        'The following node(s): \n %s \n have more than one successors.',...
        implode(g.Nodes.Name(outdegree(g)>1),','));
    
    % There must be at most one node that has no predecessors
    assert(length(find(indegree(g)==0)) <= 1,...
        'There are more than one nodes that have no predecessors.')
    
    % There must be at most one node that has no successors
    assert(length(find(outdegree(g)==0)) <= 1,...
        'There are more than one nodes that have no successors.')
end