function obj = setMassMatrix(obj, M)
    % Set the mass matrix M(x) of the system
    %
    % Parameters:
    %  M:  the mass matrix M(x) @type SymFunction
    
    x = obj.States.x;
    mmat_name = ['Mmat_',obj.Name];
    mmat_ddx_name = ['MmatDx_' obj.Name];
    % validate and set the mass matrix M(x)
    if ~isempty(M)
        
        [nr,nc] = size(M);
        assert(nr==obj.numState && nc==obj.numState,...
            'The size of the mass matrix should be (%d x %d).',obj.numState,obj.numState);
        if isa(M,'SymFunction')            
            obj.Mmat = M;
            assert((length(M.Vars)==1 && M.Vars{1} == x) || isempty(M.Vars),...
                'The SymFunction (M) must be a function of only states (x).');
        else
            M = SymExpression(M);
            obj.Mmat = SymFunction(mmat_name,M,{x});
        end
        
        if strcmp(obj.Type,'SecondOrder') 
            ddx = obj.States.ddx;
            obj.MmatDx = SymFunction(mmat_ddx_name,-obj.Mmat*ddx,{x,ddx});
        else
            dx = obj.States.dx;
            obj.MmatDx = SymFunction(mmat_ddx_name,-obj.Mmat*dx,{x,dx});
        end
    else
        obj.Mmat = [];
        if strcmp(obj.Type,'SecondOrder') 
            ddx = obj.States.ddx;
            obj.MmatDx = SymFunction(mmat_ddx_name,-ddx,{x,ddx});
        else
            dx = obj.States.dx;
            obj.MmatDx = SymFunction(mmat_ddx_name,-dx,{x,dx});
        end
    end
    
    obj.MmatName_ = mmat_name;
      
end
