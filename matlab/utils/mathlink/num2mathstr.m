function s = num2mathstr(x, varargin)
        
    if isinf(x)
        s = 'Infinity';
    elseif isequal(fix(x),x) % integer
        s = num2str(x);
    else
        % x = roundn(x,-9);
        s = num2str(x,'%.6f');
    end
end