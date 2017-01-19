function [value, isterminal, direction] = checkGuard(obj, t, x, cur_node, assoc_edges)
    % Detect the guard condition (event trigger)
    %
    % Parameters:
    %  t: the absolute time @type double
    %  x: the system states @type colvec
    %  cur_domain: the current domain 
    %  assoc_edges: a table of transition edges from the current domain
    %  @type table
    
    
    
    model = obj.Model;
    cur_domain = cur_node.Domain{1};
    cur_control = cur_node.Control{1};
    % Extract states to angles and velocities
    qe  = x(model.qeIndices);
    dqe = x(model.dqeIndices);

    % compute naturual dynamics
    [De, He] = calcNaturalDynamics(model, qe , dqe);


    [vfc, gfc] = calcVectorFields(cur_domain, model, qe, dqe, De, He);


    % compute control input
    u = calcControl(cur_control, t, qe, dqe, vfc, gfc, cur_domain);
    
    num_edges = height(assoc_edges);
    guards = assoc_edges.Guard;
    
    direction  = cellfun(@(x)x.Direction, guards);
    isterminal = ones(1, num_edges);
    
    conditions = cellfun(@(x)x.Condition, guards, 'UniformOutput', false);
    
    raw_value = calcUnilateralCondition(cur_node.Domain{1}, conditions, model, qe, dqe, u);
    thresholds = cellfun(@(x)calcThreshold(x, t, qe, dqe), guards);
    
    value = raw_value - thresholds;
    
    
end
