function M = calcMassMatrix(obj, x)
    % calculates the mass matrix Mmat(x)
    %
    % Parameters:
    % x: the state variables @type colvec

    %     validateattributes(x, {'double'},...
    %         {'vector','numel',obj.numState,'real'},...
    %         'ContinuousDynamics.calcMassMatrix','x');
    if isempty(obj.Mmat)
        M = [];
        return;
    end
    
    Mmat_name = obj.MmatName_;
    n_fun = length(Mmat_name);
    M = zeros(obj.numState);
    for i=1:n_fun
        M = M + feval(Mmat_name{i},x);
    end
end