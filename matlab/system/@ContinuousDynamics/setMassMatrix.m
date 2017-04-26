function obj = setMassMatrix(obj, M)
    % Set the mass matrix M(x) of the system
    %
    % Parameters:
    %  M:  the mass matrix M(x) @type SymFunction
    
    x = obj.States.x;
    % validate and set the mass matrix M(x)
    if ~isempty(M)
        
        [nr,nc] = size(M);
        assert(nr==obj.numState && nc==obj.numState,...
            'The size of the mass matrix should be (%d x %d).',obj.numState,obj.numState);
        if isa(M,'SymFunction')
            assert(length(M.Vars)==1 && M.Vars{1} == x,...
                'The SymFunction (M) must be a function of only states (x).');
            obj.Mmat = M;
        else
            M = SymExpression(M);
            obj.Mmat = SymFunction(['Mmat_',obj.Name],M,{x});
        end
        
        if strcmp(obj.Type,'SecondOrder') 
            ddx = obj.States.ddx;
            obj.MmatDx = SymFunction(['MmatDDx_' obj.Name],-obj.Mmat*ddx,{x,ddx});
        else
            dx = obj.States.dx;
            obj.MmatDx = SymFunction(['MmatDx_' obj.Name],-obj.Mmat*dx,{x,dx});
        end
    else
        obj.Mmat = [];
        if strcmp(obj.Type,'SecondOrder') 
            ddx = obj.States.ddx;
            obj.MmatDx = SymFunction(['MmatDDx_' obj.Name],-ddx,{x,ddx});
        else
            dx = obj.States.dx;
            obj.MmatDx = SymFunction(['MmatDx_' obj.Name],-dx,{x,dx});
        end
    end
    
    
      
end