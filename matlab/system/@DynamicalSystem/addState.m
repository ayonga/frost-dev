function obj = addState(obj, x, dx, ddx)
    % Add state variables of the dynamical system
    %
    % Parameters:
    %  x: the symbolic variables of the states @type SymVariable
    %  dx: the symbolic variables of the first order derivatives of
    %  states @type SymVariable
    %  ddx: the symbolic variables of the second order derivatives of
    %  states @type SymVariable
    
    assert(isa(x,'SymVariable') && isvector(x), ...
        '(x) must be a vector SymVariable object.');
    
    assert(isa(dx,'SymVariable') && isvector(dx), ...
        '(dx) must be a vector SymVariable object.');
    
    assert(length(dx) == length(x),...
        'The dimension of (dx) is incorrect.');
    
    if nargin > 3
        if ~isempty(ddx)
            assert(isa(ddx,'SymVariable') && isvector(x), ...
                '(ddx) must be a vector SymVariable object.');
            
            assert(length(ddx) == length(x),...
                'The dimension of (ddx) is incorrect.');
            
        end
    else
        ddx = [];
    end

    obj.States.x = x;
    obj.States.dx = dx;
    obj.States.ddx = ddx;
    obj.numState = length(obj.States.x);
end
