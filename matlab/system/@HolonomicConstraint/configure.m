function obj = configure(obj)
    % compiles the derivatives and Jacobian of the actual/desired
    % outputs functions
    
    model = obj.Model;
    x = model.States.x;
    dx = model.States.dx;
    
    name = obj.Name;
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
        obj.dh_ = SymFunction(['dh_' name '_' model.Name], dh, {x,dx});
        
        dJh = jacobian(dh, x);
        obj.dJh_ = SymFunction(['dJh_' name '_' model.Name], dJh, {x, dx});
        ddh = Jh*ddx + dJh*dx;
        obj.ddh_ = SymFunction(['ddh_' name '_' model.Name], ddh, {x, dx, ddx});
        
        obj.dh_name = obj.dh_.Name;
        obj.ddh_name = obj.ddh_.Name;
        obj.dJh_name = obj.dJh_.Name;
    else
        if order == 2
            M = model.Mmat;
            F = sum(horzcat(model.Fvec{:}),2);
            dX = M\F;
            dh = Jh * dX;
            obj.dh_ = SymFunction(['dh_' name '_' model.Name], dh, {x});
            
            dJh = jacobian(dh, x);
            obj.dJh_ = SymFunction(['dJh_' name '_' model.Name], dJh, {x});
            ddh = dJh*dx;
            obj.ddh_ = SymFunction(['ddh_' name '_' model.Name], ddh, {x, dx});
            obj.dh_name = obj.dh_.Name;
            obj.ddh_name = obj.ddh_.Name;
            obj.dJh_name = obj.dJh_.Name;
        else
            dh = Jh * dx;
            obj.dh_ = SymFunction(['dh_' name '_' model.Name], dh, {x,dx});
            obj.dh_name = obj.dh_.Name;
        end
        
        
    end
    
    obj.h_name = obj.h_.Name;
    obj.Jh_name = obj.Jh_.Name;
    
            
end