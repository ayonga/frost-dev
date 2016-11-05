function obj = genConstrIndices(obj, solver)
    % This function generates the indexing information for
    % constraints
    %
    % @note Indexing NLP constraints depends on different NLP
    % solver being used. By default, we assume 'ipopt' being used,
    % with which all constraints are catagorized into one big
    % group. If 'fmincon' being used, then there will be
    % linear/nonlinear and equality/inequality constraints, and
    % each group of constraints are indexed separately.
    %
    % Parameters:
    %  solver: a string indicates the NLP solver being used @type
    %  char @default 'ipopt'
    
    
    if nargin < 2 % default solver 'ipopt'
        solver = 'ipopt';
    end
    
    switch solver
        case 'ipopt'
            obj = genConstrIndicesIpopt(obj);
        case 'fmincon'
            %| @todo implement indexing function for fmincon
        case 'snopt'
            %| @todo implement indexing function for snopt
        otherwise
            error('%s is not supported in the current version.\n',solver);
    end
    
    
end