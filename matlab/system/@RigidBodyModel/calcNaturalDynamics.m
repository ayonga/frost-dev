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
    qe  = x(obj.qe_indices);
    dqe = x(obj.dqe_indices);
        
%     if obj.options.use_sva
%         [De, He] = HandC(obj.sva, qe, dqe);
%     else
        De = De_mat(qe); % inertia matrix
        Ce = Ce_mat(qe, dqe); % coriolis matrix
        Ge = Ge_vec(qe); % gravity vector
        He = Ce*dqe + Ge;
%     end
    
    
end
