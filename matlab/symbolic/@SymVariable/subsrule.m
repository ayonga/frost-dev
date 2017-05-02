function rule = subsrule(obj, name)
    % Return the string subsititution rule for the symbolic variable vector
    %
    % Return values:
    % rule: the string subsititution rules @type SymExpression
    
    
    assert(isempty(regexp(name, '\W', 'once')),...
        'SymExpression:invalidSymbol', ...
        'Invalid symbol name, can NOT contain special characters.');
    
    assert(isempty(regexp(name, '_', 'once')),...
        'SymExpression:invalidSymbol', ...
        'Invalid symbol name, can NOT contain ''_''.');
    
    if isscalar(obj)
        str = eval_math(['{' obj.s, '->HoldForm@Global`', name,'[[0]]}'],false);
        rule = SymExpression(str);
    elseif isvectorform(obj)
        siz = numel(obj);
        fstr= obj.s;
        str = eval_math(['((' fstr '[[#+1]]-> HoldForm@Global`', name '[[#]]&)/@(Range[', num2str(siz),']-1))']);
        rule = SymExpression(str,false);
    elseif ismatrix(obj)
        siz = numel(obj);        
        fsym= tovector(obj);
        fstr = fsym.s;
        str = eval_math(['((' fstr '[[#+1]]-> HoldForm@Global`', name '[[#]]&)/@(Range[', num2str(siz),']-1))']);
        rule = SymExpression(str,false);
    else
        error('Unsupported format.');
    end
    
    
    
    
end