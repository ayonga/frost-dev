function [De, He] = calcNaturalDynamics(obj, x)
    % This function compute the natural unconstrained dynamics of the rigid
    % body model.
    %
    % Parameters:
    %  x: the system states @type colvec
    % Return values:
    %  De: the inertia matrix @type matrix
    %  He: the corilios and gravity term @type colvec
    
    % Extract states to angles and velocities
    qe  = x(model.qeIndices);
    dqe = x(model.dqeIndices);
        
    if obj.options.use_sva
        [De, He] = HandC(obj.sva, qe, dqe);
    else
        De = De_mat(x); % inertia matrix
        Ce = Ce_mat(x); % coriolis matrix
        Ge = Ge_vec(x); % gravity vector
        He = Ce*dqe + Ge;
    end
    
    
end