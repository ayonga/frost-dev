function obj = addInput(obj, u, F)
    % Add input variables of the dynamical system
    %
    % Parameters:
    %  u: the symbolic variables of the control inputs @type SymVariable
    %  F: the symbolic variables of the external forces (or Lagrangian
    %  multiplier)  @type SymVariable
    
    
    assert(isa(u,'SymVariable') && isvector(u), ...
        '(u) must be a vector SymVariable object.');
    obj.Inputs.u = u;
    obj.numControl = length(u);
    
    
    if nargin > 2
        
        assert(isa(F,'SymVariable') && isvector(F), ...
            '(F) must be a vector SymVariable object.');
        obj.Inputs.f = F;
        obj.numExternal = length(F);
    else
        obj.Inputs.f = [];
        obj.numExternal = 0;
    end
    
    
    
    
end