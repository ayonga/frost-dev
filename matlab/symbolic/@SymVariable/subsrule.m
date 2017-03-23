function rule = subsrule(obj)
    % Return the string subsititution rule for the symbolic variable vector
    %
    % Return values:
    % rule: the string subsititution rules @type SymExpression
    
    
    str_replace = @(x)regexprep(x,'\$','_');
    
    if isscalar(obj)
        rule = SymExpression(['{' obj.f, '->HoldForm@Global`', str_replace(obj.name),'[[0]]}']);
    elseif isvector(obj)
        siz = numel(obj);
        fstr= obj.s;
        rule = SymExpression(['((' fstr '[[#+1]]-> HoldForm@Global`', str_replace(obj.name) '[[#]]&)/@(Range[', num2str(siz),']-1))'],false);
    elseif ismatrix(obj)
        siz = numel(obj);        
        fsym= flatten(obj);
        fstr = fsym.s;
        rule = SymExpression(['((' fstr '[[#+1]]-> HoldForm@Global`', str_replace(obj.name) '[[#]]&)/@(Range[', num2str(siz),']-1))'],false);
    else
        error('Unsupported format.');
    end
    
    
    
    
end