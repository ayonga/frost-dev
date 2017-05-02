function obj = setTwistPairs(obj, dofs, q)
    % set the twist paris of all precedent joints
    %
    % Parameters:
    % dofs: the array of rigid joints @type RigitJoint
    % q: the symbolic variabls of rigid joints @type SymVariable
    
    assert(length(dofs)==length(q),...
        'The length of (dofs) and (q) must be the same.');
    
    indices = obj.ChainIndices;
    
    if isempty(indices)
        error('Please updates the kinemetic chain indcies first (setChainIndices).');
    end
    
    n_paris = numel(indices);
    twist_pairs = cell(1,n_paris);
    for i=1:n_paris
        idx = indices(i);
        twist = dofs(idx).Twist;
        if isempty(twist)
            computeTwist(dofs(idx));
            twist = dofs(idx).Twist;
        end
        
        t_s = mat2math(twist);
        q_s = char(q(idx));
        
        twist_pairs{i} = SymExpression({[t_s(2:end-1) ',' q_s(2:end-1)]});
        
    end
    %             if isscalar(twist_pairs)
    %                 twist_pairs = {twist_pairs};
    %             end
    obj.TwistPairs = twist_pairs;
end