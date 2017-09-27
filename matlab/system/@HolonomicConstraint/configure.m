function obj = configure(obj)
    % configure the derivatives and Jacobian of the actual/desired
    % outputs functions
    
    model = obj.Model;
    x = model.States.x;
    dx = model.States.dx;
    
    if isempty(obj.DerivativeOrder)
        obj.DerivativeOrder = 2;
    end
    order = obj.DerivativeOrder;
    
    if isempty(obj.Jh_)
        obj.setJacobian();
    end
    Jh = obj.Jh_;
        
    if strcmp(model.Type,'SecondOrder')
        if order ~= 2
            assert('The holonomic constraint of the second-order system must be 2.');
        end
        ddx = model.States.ddx;
        dh = Jh * dx;
        obj.dh_ = SymFunction(obj.dh_name, dh, {x,dx});
        
        dJh = jacobian(dh, x);
        obj.dJh_ = SymFunction(obj.dJh_name, dJh, {x, dx});
        ddh = Jh*ddx + dJh*dx;
        obj.ddh_ = SymFunction(obj.ddh_name, ddh, {x, dx, ddx});
        
    else
        if order == 2
            M = model.Mmat;
            F = sum(horzcat(model.Fvec{:}),2);
            dX = M\F;
            dh = Jh * dX;
            obj.dh_ = SymFunction(obj.dh_name, dh, {x});
            
            dJh = jacobian(dh, x);
            obj.dJh_ = SymFunction(obj.dJh_name, dJh, {x});
            ddh = dJh*dx;
            obj.ddh_ = SymFunction(obj.ddh_name, ddh, {x, dx});
        else
            dh = Jh * dx;
            obj.dh_ = SymFunction(obj.dh_name, dh, {x,dx});
        end
        
        
    end
    
            
end