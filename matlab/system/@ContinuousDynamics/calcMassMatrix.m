function M = calcMassMatrix(obj, q)
    % calculates the mass matrix Mmat(x)
    %
    % Parameters:
    % q: the state variables @type colvec

    %     validateattributes(x, {'double'},...
    %         {'vector','numel',obj.numState,'real'},...
    %         'ContinuousDynamics.calcMassMatrix','x');
  
    
    if isempty(obj.Mmat)
        M = [];
        return;
    end
    
    Mmat_name = obj.MmatName_;
    n_fun = length(Mmat_name);
    M = zeros(obj.Dimension);
    
    for i=1:n_fun
        M = M + feval(Mmat_name{i},q);
    end
        
end