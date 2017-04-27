function [value, isterminal, direction] = checkGuard(obj, t, x, cur_node, guards)
    % Detect the guard condition (event trigger)
    %
    % Parameters:
    %  t: the absolute time @type double
    %  x: the system states @type colvec
    %  cur_domain: the current domain 
    %  assoc_edges: a table of transition edges from the current domain
    %  @type table
    
    
    
    
    
    n_edges = length(guards);
    % we always assumes that the guard function is from positive to
    % negative
    direction  = -ones(1, n_edges); % -1: pos->neg
    isterminal = ones(1, n_edges);  % all are terminal
    
    % call the event function of each guard to compute the value of events
    value = ones(1,n_edges);
    for i=1:n_edges
        value(i) = guards{i}.calcEvent(t,x,cur_node);
    end
    
end
