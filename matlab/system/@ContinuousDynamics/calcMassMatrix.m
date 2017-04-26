function M = calcMassMatrix(obj, x)
    % calculates the mass matrix Mmat(x)
    %
    % Parameters:
    % x: the state variables @type colvec

    validateattributes(x, {'double'},...
        {'vector','numel',obj.numState,'real'},...
        'ContinuousDynamics.calcMassMatrix','x');

    M = feval(obj.Mmat.Name, qe);
end