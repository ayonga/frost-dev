function obj = configure(obj, load_path)
    % configure the derivatives and Jacobian of the actual/desired
    % outputs functions
    %
    % Parameters:
    %  load_path: the path from which symbolic expressions can be loaded
    %  @type char
    
    if ~exist('load_path','var')
        load_path = [];
    end
    
    model = obj.Model;
    x = model.States.x;
    dx = model.States.dx;
    hd = obj.Param;
    
    
    if isempty(obj.DerivativeOrder)
        obj.DerivativeOrder = 2;
    end
    order = obj.DerivativeOrder;
    
    if isempty(load_path)
        if isempty(obj.Jh_)
            obj.setJacobian();
        end
    end
    Jh = obj.Jh_;
        
    
    
    if strcmp(model.Type,'SecondOrder')
        if order ~= 2
            assert('The holonomic constraint of the second-order system must be 2.');
        end
        if isempty(load_path)
            ddx = model.States.ddx;
            dh = Jh * dx;
            obj.dh_ = SymFunction(obj.dh_name, dh, {x,dx});
            
            dJh = jacobian(dh, x);
            obj.dJh_ = SymFunction(obj.dJh_name, dJh, {x, dx});
            ddh = Jh*ddx + dJh*dx + obj.dh_ + obj.h_;
            obj.ddh_ = SymFunction(obj.ddh_name, ddh, {x, dx, ddx, hd});
        else
            ddx = model.States.ddx;
            dh = SymFunction(obj.dh_name, [], {x,dx});
            obj.dh_ = load(dh, load_path);
            
            
            dJh = SymFunction(obj.dJh_name, [], {x,dx});
            obj.dJh_ = load(dJh, load_path);
            
            ddh = SymFunction(obj.ddh_name, [], {x, dx, ddx, hd});
            obj.ddh_ = load(ddh, load_path);
        end
    else
        if isempty(load_path)
            if order == 2
                M = model.Mmat;
                F = sum(horzcat(model.Fvec{:}),2);
                dX = M\F;
                dh = Jh * dX;
                obj.dh_ = SymFunction(obj.dh_name, dh, {x});
                
                dJh = jacobian(dh, x);
                obj.dJh_ = SymFunction(obj.dJh_name, dJh, {x});
                ddh = dJh*dx + obj.dh_ + obj.h_;
                obj.ddh_ = SymFunction(obj.ddh_name, ddh, {x, dx, hd});
            else
                dh = Jh * dx + obj.h_;
                obj.dh_ = SymFunction(obj.dh_name, dh, {x, dx, hd});
            end
        else
            if order == 2
                dh = SymFunction(obj.dh_name, [], {x});
                obj.dh_ = load(dh, load_path);
                
                
                dJh = SymFunction(obj.dJh_name, [], {x});
                obj.dJh_ = load(dJh, load_path);
                
                ddh = SymFunction(obj.ddh_name, [], {x, dx, hd});
                obj.ddh_ = load(ddh, load_path);
                
                
            else
                dh = SymFunction(obj.dh_name, [], {x,dx, hd});
                obj.dh_ = load(dh, load_path);
            end
            
        end
        
    end
    
            
end