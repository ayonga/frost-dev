function obj = loadDynamics(obj,file_path,skip_load_vf,extra_fvecs,varargin)
    % Load the symbolic expression of dynamical equations from a previously
    % save MX files
    %
    % Parameters:
    %  file_path: the path to export the file @type char
    %  skip_load_vf: skip loading the drift vectors @type logical
    %  extra_fvecs: list of extra drift vectors @type cellstr
    
    
    n_mmat = length(obj.Links)+1;
    for i=1:n_mmat
        mmat_names{i} = ['Mmat' num2str(i) '_' obj.Name];
        mmat_ddx_names{i} = ['MmatDx' num2str(i) '_' obj.Name];
    end
    
    if nargin < 4
        extra_fvecs = {};
    end
    
    if ~iscell(extra_fvecs), extra_fvecs = {extra_fvecs}; end
    
    if nargin < 5
        omit_set = false;
    else
        opts = struct(varargin{:});
        if isfield(opts, 'OmitCoriolisSet')
            omit_set = opts.OmitCoriolisSet;
        else
            omit_set = false;
        end
    end
    if ~omit_set
        ce_names1 = cell(obj.numState*n_mmat,1);
        ce_names2 = cell(obj.numState*n_mmat,1);
        ce_names3 = cell(obj.numState*n_mmat,1);
        for i=1:n_mmat
            for j=1:obj.numState
                ce_names1{(i-1)*obj.numState+j} = ['Ce1_vec_L',num2str(i),'_J',num2str(j),'_', obj.Name];
                ce_names2{(i-1)*obj.numState+j} = ['Ce2_vec_L',num2str(i),'_J',num2str(j),'_', obj.Name];
                ce_names3{(i-1)*obj.numState+j} = ['Ce3_vec_L',num2str(i),'_J',num2str(j),'_', obj.Name];
            end
        end
    else
        ce_names1 = {};
        ce_names2 = {};
        ce_names3 = {};
    end
    Ge = ['Ge_vec_',obj.Name];
    
    vf_names = [ce_names1;ce_names2;ce_names3;{Ge};extra_fvecs];
    
    % call superclass method
    if nargin < 3
        skip_load_vf = false;
    end
    loadDynamics@ContinuousDynamics(obj, file_path, mmat_names, mmat_ddx_names, vf_names, skip_load_vf);
end