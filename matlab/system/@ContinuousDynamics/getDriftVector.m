function f = getDriftVector(obj)
    % returns the symbolic expression of the total drift vector (summing
    % all sub-vectors together)
    %

    f = tomatrix(sum([obj.Fvec{:}],2));
    
    
end