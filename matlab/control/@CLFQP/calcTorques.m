function [u, extra] = calcControl(obj, t, qe, dqe, vfc, gfc, domain)
    % Computes the classical input-output feedback linearization
    % control law for virtual constraints
    %
    % Parameters:
    % t: the time instant @type double
    % qe: the joint configuration @type colvec
    % dqe: the joint velocities @type colvec
    % vfc: the vector field f(x) @type colvec
    % gfc: the vector field g(x) @type colvec
    % domain: the continuous domain @type Domain
    %
    % Return values:
    % u: the computed torque @type colvec
    % extra: additional computed data @type struct
    error('This class has not been completely defined yet.');
    
end