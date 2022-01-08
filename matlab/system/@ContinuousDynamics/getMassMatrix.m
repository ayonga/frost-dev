function M = getMassMatrix(obj)
    % returns the symbolic expression of the total mass matrix (summing
    % all sub-matrix together)
    %

    n_fun = length(obj.MmatName_);
    M = obj.Mmat{1};
    for i=2:n_fun
        M = M + obj.Mmat{i};
    end
    
    M = tomatrix(M);
    
    
end