function obj = loadDynamics(obj,file_path,skip_load_vf)
    % Load the symbolic expression of dynamical equations from a previously
    % save MX files
    %
    % Parameters:
    %  file_path: the path to export the file @type char
    %  skip_load_vf: skip loading the drift vectors @type logical
    
    mmat_name = []; % we use the default name
    mmat_ddx_name = []; % we use the default name
    
    ce_names1 = cell(obj.numState,1);
    ce_names2 = cell(obj.numState,1);
    ce_names3 = cell(obj.numState,1);
    for i=1:obj.numState
        ce_names1{i} = ['Ce1_vec',num2str(i),'_',obj.Name];
        ce_names2{i} = ['Ce2_vec',num2str(i),'_',obj.Name];
        ce_names3{i} = ['Ce3_vec',num2str(i),'_',obj.Name];
    end
    Ge = ['Ge_vec_',obj.Name];
    
    vf_names = [ce_names1;ce_names2;ce_names3;{Ge}];
    
    % call superclass method
    if nargin < 3
        skip_load_vf = false;
    end
    loadDynamics@ContinuousDynamics(obj, file_path, mmat_name, mmat_ddx_name, vf_names, skip_load_vf);
end