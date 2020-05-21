function obj = setMassMatrix(obj, Mlist)
    % Set the mass matrix M(x) of the system
    %
    % Parameters:
    %  M:  the mass matrix M(x) @type SymFunction
    
    x = obj.States.x;
    
    % validate and set the mass matrix M(x)
    if ~iscell(Mlist), Mlist = {Mlist}; end
    
    if ~isempty(Mlist)
        
        m = 100;
        fprintf('Setting the inertia matrix D(q): \t');
        bs = '\b';
        sp = ' ';
        msg = '%d percents completed.\n'; % carriage return included in case error interrupts loop
        msglen = length(msg)-3; % compensate for conversion character and carriage return
        fprintf(1,sp(ones(1,ceil(log10(m+1))+msglen)));
        n_mmat = numel(Mlist);
        for i=1:n_mmat
            M = Mlist{i};
            mmat_name = ['Mmat' num2str(i) '_' obj.Name];
            mmat_ddx_name = ['MmatDx' num2str(i) '_' obj.Name];
            [nr,nc] = size(M);
            assert(nr==obj.numState && nc==obj.numState,...
                'The size of the mass matrix should be (%d x %d).',obj.numState,obj.numState);
            if isa(M,'SymFunction')                
                assert((length(M.Vars)==1 && M.Vars{1} == x) || isempty(M.Vars),...
                    'The SymFunction (M) must be a function of only states (x).');
            else
                M = SymFunction(mmat_name,SymExpression(M),{x});
                assert((length(M.Vars)==1 && M.Vars{1} == x) || isempty(M.Vars),...
                    'The SymFunction (M) must be a function of only states (x).');
            end
            obj.Mmat{i} = M;
            
            
            if strcmp(obj.Type,'SecondOrder')
                ddx = obj.States.ddx;
            else
                ddx = obj.States.dx;
            end
            obj.MmatDx{i} = SymFunction(mmat_ddx_name,['Normal[SparseArray[' M.s '].SparseArray[-' ddx.s ']]'],{x,ddx});
            k = floor(i*100/n_mmat);
            fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
        end
    else
        mmat_ddx_name = ['MmatDx_' obj.Name];
        obj.Mmat = [];
        if strcmp(obj.Type,'SecondOrder') 
            ddx = obj.States.ddx;
            obj.MmatDx = SymFunction(mmat_ddx_name,-ddx,{x,ddx});
        else
            dx = obj.States.dx;
            obj.MmatDx = SymFunction(mmat_ddx_name,-dx,{x,dx});
        end
    end
    
    obj.MmatName_ = cellfun(@(f)f.Name, obj.Mmat,'UniformOutput',false);
    
end
