function obj = configure(obj, model, load_path)
    % configure the derivatives and Jacobian of the actual/desired
    % outputs functions
    %
    % Parameters:
    %  obj: the object itself
    %  model: the associated dynamics system model @type DynamicalSystem
    %  load_path: the path from which symbolic expressions can be loaded
    %  @type char
    
    
    x = model.States.x;
    dx = model.States.dx;
    
    if ~isempty(load_path)
        Jh = SymFunction(obj.Jh_name, [], {x});
        load(Jh,load_path);
        obj.setJacobian(Jh, model);
    else
        if isempty(obj.Jh_)
            jac = jacobian(obj.h_, x);
            obj.Jh_ = SymFunction(obj.Jh_name, jac, {x});
        end
    end
    
    Jh = obj.Jh_;
    
    if strcmp(obj.SystemType,'SecondOrder')
        if isempty(load_path)
            
            dh = Jh * dx;
            obj.dh_ = SymFunction(obj.dh_name,dh,{x,dx});
            
            dJh = jacobian(obj.dh_, x);
            % dt = 1e-3;
            % x_n = x+dx.*dt;
            % Jh_n = subs(obj.Jh_,x,x_n);
            % dJh = (Jh_n - obj.Jh_)./dt;
            obj.dJh_ = SymFunction(obj.dJh_name, dJh, {x, dx});
            
            ddx = model.States.ddx;
            ddh = Jh*ddx + dJh*dx;% + obj.dh_ + obj.h_;
            obj.ddh_ = SymFunction(obj.ddh_name, ddh, {x, dx, ddx});
            
        else
            dh = SymFunction(obj.dh_name, [], {x,dx});
            obj.dh_ = load(dh, load_path);
            
            
            dJh = SymFunction(obj.dJh_name, [], {x,dx});
            obj.dJh_ = load(dJh, load_path);
            
            
            ddx = model.States.ddx;
            ddh = SymFunction(obj.ddh_name, [], {x, dx, ddx});
            obj.ddh_ = load(ddh, load_path);
        end
    else
        if isempty(load_path)
            if obj.RelativeDegree == 2
                M = model.getMassMatrix();
                F = model.getDriftVector();
                dX = M\F;
                dh = Jh * dX;
                obj.dh_ = SymFunction(obj.dh_name, dh, {x});
                
                dJh = jacobian(dh, x);
                obj.dJh_ = SymFunction(obj.dJh_name, dJh, {x});
                
                ddh = dJh*dx;
                obj.ddh_ = SymFunction(obj.ddh_name, ddh, {x, dx});
            else
                dh = Jh * dx;
                obj.dh_ = SymFunction(obj.dh_name, dh, {x, dx});
            end
        else
            if obj.RelativeDegree == 2
                dh = SymFunction(obj.dh_name, [], {x});
                obj.dh_ = load(dh, load_path);
                
                
                dJh = SymFunction(obj.dJh_name, [], {x});
                obj.dJh_ = load(dJh, load_path);
                
                ddh = SymFunction(obj.ddh_name, [], {x, dx});
                obj.ddh_ = load(ddh, load_path);
                
                
            else
                dh = SymFunction(obj.dh_name, [], {x,dx});
                obj.dh_ = load(dh, load_path);
            end
            
        end
        
    end
    
    
            
end