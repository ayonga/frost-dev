function [M,f] = calcDynamics(obj, qe, dqe)
    % Calculated the Lagrangian dynamics of the mechanical system given the
    % joint configuration (qe) and the velocities (dqe).
    %
    % Parameters:
    %  qe: the joint configurations @type colvec
    %  dqe: the joint velocities @type colvec
    
    assert(length(qe)==obj.numState && isvector(qe),...
        'The joint configuration (qe) must be a (%d x 1) vector.',obj.numState);
    assert(length(dqe)==obj.numState && isvector(dqe),...
        'The joint velocities (dqe) must be a (%d x 1) vector.',obj.numState);
    
    M = feval(obj.Mmat.Name, qe);
    f_val = cellfun(@(x)feval(x.Name,qe,dqe), obj.Fvec,'UniformOutput',false);
    
    f = sum([f_val{:}],2);
    
end