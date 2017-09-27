function obj = loadExpression(obj, file_path, varargin)
    % load the symbolic expressions related to the holonomic constraints
    % from MX binary files for fast loading
    %
    % Parameters:
    %  file_path: the path to the files @type char
    %  varargin: optional parameters. In details
    %    ConstrLabel:
    %    Jacobian:
    
    
            
            
    
    model = obj.Model;
    x = model.States.x;
    dx = model.States.dx;
    
    
    
    h = SymExpression([]);
    h = load(h, file_path, obj.h_name);
    
    dim = length(h);
    obj.Dimension = dim;
    
    hd = SymVariable(obj.ParamName, [dim,1]);
    obj.Param = hd;
    obj.Input = SymVariable(obj.InputName,[dim,1]);
    % the loaded expression is h:= h_a - h_d
    obj.h_ = SymFunction(obj.h_name, h, {x, hd}); 
    
    Jh = SymFunction(obj.Jh_name, [], {model.States.x});
    obj.Jh_ = load(Jh,file_path);
   
    
    % parse the input options
    args = struct(varargin{:});
    assert(isscalar(args),...
        'The values of optional properties are must be scalar data.');
    
    
    % validate and assign the desired outputs
    if isfield(args, 'ConstrLabel')
        obj.setConstrLabel(args.ConstrLabel);
    end
    
    
    if isfield(args, 'DerivativeOrder')
        obj.setDerivativeOrder(args.DerivativeOrder);
    else
        obj.setDerivativeOrder(2);
    end    
    order = obj.DerivativeOrder;
        
    if strcmp(model.Type,'SecondOrder')
        if order ~= 2
            assert('The holonomic constraint of the second-order system must be 2.');
        end
        ddx = model.States.ddx;
        dh = SymFunction(obj.dh_name, [], {x,dx});
        obj.dh_ = load(dh, file_path);
        
        
        dJh = SymFunction(obj.dJh_name, [], {x,dx});
        obj.dJh_ = load(dJh, file_path);
        
        ddh = SymFunction(obj.ddh_name, [], {x, dx, ddx});
        obj.ddh_ = load(ddh, file_path);
        
       
    else
        if order == 2
            dh = SymFunction(obj.dh_name, [], {x});
            obj.dh_ = load(dh, file_path);
            
            
            dJh = SymFunction(obj.dJh_name, [], {x});
            obj.dJh_ = load(dJh, file_path);
            
            ddh = SymFunction(obj.ddh_name, [], {x, dx});
            obj.ddh_ = load(ddh, file_path);
            
            
        else
            dh = SymFunction(obj.dh_name, [], {x,dx});
            obj.dh_ = load(dh, file_path);
        end
        
        
    end
    
            
end