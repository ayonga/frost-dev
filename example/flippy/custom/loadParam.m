function [params,x0] = loadParam(param_config_file)
    
    
    old_params = cell_to_matrix_scan(yaml_read_file(param_config_file));
    
    % flippy.Params
    params = struct();
    params.avel = old_params.domain(1).v;
    params.pvel = old_params.domain(1).p(1:2)';
    params.apos = old_params.domain(1).a;
    params.ppos = old_params.domain(1).p(1:2)';
    
    % will be used 
    params.kvel = 10;
    params.kpos = [100,20]; %[kp,kd]
    
    x0 = old_params.domain(1).x_plus([7:12 19:end]);
    
end