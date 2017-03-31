function obj = constrainedEquation(obj, h, Jh, dJh)
    % Configure the constrained equation of the system
    %
    % Parameters:
    %  h: the constraint equation h(x) @type SymExpression
    %  Jh: the Jacobian of constraints Jh(x) w.r.t to the states
    %  @type SymExpression
    %  dJh:  the time derivative of the Jacobian of constraints
    %  Jh(x)  @type SymExpression
    
    if nargin < 3
        Jh = [];
    end
    if nargin < 4
        dJh = [];
    end
    
    assert(isvector(h) && isa(h,'SymExpression'),...
        'The constraints (h) must be a vector SymExpression object.');
    obj.ConstraintEqn.h = h;
    
    if ~isempty(Jh)
        assert(isa(Jh,'SymExpression'),...
            'The second argument (Jh) must be a SymExpression object.');
        [nr,nc] = size(Jh);
        
        assert(nc==obj.numState && nr==length(h),...
            'The dimension of (Jh) is incorrect.');
        
        obj.Jh = Jh;
    else
        Jh = jacobian(h, obj.States.X);
    end
    obj.ConstraintEqn.Jh = Jh;
    
    
    if ~isempty(dJh)
        assert(isa(dJh,'SymExpression'),...
            'The third argument (dJh) must be a SymExpression object.');
        [nr,nc] = size(dJh);
        
        assert(nc==obj.numState && nr==length(h),...
            'The dimension of (dJh) is incorrect.');
    else
        if isa(obj,'SecondOrderSystem')
            dJh = jacobian(Jh*obj.States.dX, obj.X);
        end
    end
    obj.ConstraintEqn.dJh = dJh;
end