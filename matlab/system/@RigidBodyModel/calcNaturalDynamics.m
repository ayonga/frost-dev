function [De, He] = calcNaturalDynamics(obj, qe, dqe, useSVA)
    % This function compute the natural unconstrained dynamics of the rigid
    % body model.
    %
    % Parameters:
    %  qe: the coordinate configuration @type colvec
    %  dqe: the coordinate velocity @type colvec
    %  useSVA: indicates whether to use SVA package to compute 
    %  dynamics  @type logical @default false
    % Return values:
    %  De: the inertia matrix @type matrix
    %  He: the corilios and gravity term @type colvec
    
    
    if nargin < 4
        useSVA = false;
    end
        
    if useSVA
        [De, He] = HandC(obj.SVA, qe, dqe);
    else
        De = De_mat(qe); % inertia matrix
        Ce = Ce_mat(qe, dqe); % coriolis matrix
        Ge = Ge_vec(qe); % gravity vector
        He = Ce*dqe + Ge;
    end
    
    
end
