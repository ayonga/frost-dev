function [dx, extra] = calcDynamics(obj, t, x, cur_node)
    % This function computes the continuous dynamics of the dynmical
    % system.
    %
    % Parameters:
    %  t: the time instant @type double
    %  x: the system states @type colvec
    %  cur_node: the current node being calculated @type table
    % Return values:
    %  dx: the first order derivatives @type colvec

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
    if nargout > 1
        [u, extra] = calcControl(cur_control, t, qe, dqe, vfc, gfc, cur_domain);
    else
        u = calcControl(cur_control, t, qe, dqe, vfc, gfc, cur_domain);
    end
    
    % Calculate the dynamics
    dx = vfc + gfc * u;

    if nargout > 1
        extra.t    = t;
        extra.qe   = qe;
        extra.dqe  = dqe;
        extra.ddqe = dx(model.dqeIndices);
        extra.vfc  = vfc;
        extra.gfc  = gfc;
        extra.u    = u;        
        extra.ue   = cur_domain.ActuationMap*u;
        extra.Fe   = calcConstraintForces(cur_domain, model, qe, dqe, u, De, He);
        % extra.domain = cur_domain;
        % extra.control = cur_control;
    end



end