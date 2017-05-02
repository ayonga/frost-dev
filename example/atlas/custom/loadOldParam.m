function params = loadOldParam(param_config_file, model)
    
    
    old_params = cell_to_matrix_scan(yaml_read_file(param_config_file));
    n_domain = length(old_params.domain);
    params = cell(1,n_domain);
    
    
    old_dofs = {'BasePosX'
        'BasePosY'
        'BasePosZ'
        'BaseRotX'
        'BaseRotY'
        'BaseRotZ'
        'l_leg_hpz'
        'l_leg_hpx'
        'l_leg_hpy'
        'l_leg_kny'
        'l_leg_aky'
        'l_leg_akx'
        'r_leg_hpz'
        'r_leg_hpx'
        'r_leg_hpy'
        'r_leg_kny'
        'r_leg_aky'
        'r_leg_akx'};
    
    q_ind = getJointIndices(model,old_dofs);
    
    
    for i=1:n_domain
        domain = old_params.domain;
        params{i}.a = domain(i).a;
        params{i}.v = domain(i).v;
        params{i}.p = domain(i).p(1:2)';
        
        q0_old = domain(i).x_plus(1:18);
        dq0_old = domain(i).x_plus(19:end);
        qf_old = domain(i).x_minus(1:18);
        dqf_old = domain(i).x_minus(19:end);
        
        q0 = zeros(model.numState,1);
        dq0 = zeros(model.numState,1);
        q0(q_ind) = q0_old;
        dq0(q_ind) = dq0_old;
        params{i}.q0 = q0;
        params{i}.dq0 = dq0;
        
        qf = zeros(model.numState,1);
        dqf = zeros(model.numState,1);
        qf(q_ind) = qf_old;
        dqf(q_ind) = dqf_old;
        
        params{i}.qf = qf;
        params{i}.dqf = dqf;
    end
    
    
    
    
end