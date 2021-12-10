function obj = loadDynamics(obj, file_path, mmat_names, mmat_ddx_names, vf_names, skip_load_vf)
    % load the symbolic expression of system dynamical equations from MX
    % binary files for fast loading
    %
    % Parameters:
    %  file_path: the path to the files @type char
    %  vf_names: the names of the drift vectors Fvec @type cellstr
    %  skip_load_vf: indicates whether to skip the loading of drift vectors
    %  which could takes a long time @type logical
    
    
    x = obj.States.x;
    % load the mass matrix using the default name 
    
    if ~isempty(mmat_names)
        
        for i=1:numel(mmat_names)
            mmat_name = mmat_names{i};
            mmat_ddx_name = mmat_ddx_names{i};
            M = SymFunction(mmat_name,[],{x});
            M = load(M,file_path);
            [nr,nc] = size(M);
            assert(nr==obj.numState && nc==obj.numState,...
                'The size of the mass matrix should be (%d x %d).',obj.numState,obj.numState);
            
            obj.Mmat{i} = M;
            
            if strcmp(obj.Type,'SecondOrder') 
                ddx = obj.States.ddx;
                MmatDx = SymFunction(mmat_ddx_name,[],{x,ddx});
            else
                dx = obj.States.dx;
                MmatDx = SymFunction(mmat_ddx_name,[],{x,dx});
            end
            MmatDx = load(MmatDx,file_path);
            obj.MmatDx{i} = MmatDx;
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
    
    
    
    % load the drift vector
    if nargin > 4
        if nargin < 6
            skip_load_vf = false;
        end
        if ~iscell(vf_names), vf_names = {vf_names}; end
        vf = cell(size(vf_names));
        for i=1:numel(vf_names)
            
            if strcmp(obj.Type,'SecondOrder') % second order system
                sfun_vf = SymFunction(vf_names{i},[],{obj.States.x,obj.States.dx});
            else                         % first order system
                sfun_vf = SymFunction(vf_names{i},[],{obj.States.x});
            end
            if ~isempty(vf_names{i}) && ~skip_load_vf
                sfun_vf = load(sfun_vf, file_path);
            end
            vf{i} = sfun_vf;
        
        end
        obj.Fvec = vf;
        obj.FvecName_ = cellfun(@(f)f.Name, vf,'UniformOutput',false);
    end
    
end