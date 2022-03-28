function [Je, Jedot] = calcConstraintsJacobian(obj, q, dq)



    %% holonomic constraints
    h_cstr_name = fieldnames(obj.HolonomicConstraints);
    if ~isempty(h_cstr_name)           % if holonomic constraints are defined
        h_cstr = struct2array(obj.HolonomicConstraints);
        n_cstr = length(h_cstr);
        % determine the total dimension of the holonomic constraints
        cdim = sum([h_cstr.Dimension]);
        % initialize the Jacobian matrix
        Je = zeros(cdim,obj.Dimension);
        Jedot = zeros(cdim,obj.Dimension);
        
        idx = 1;
        for i=1:n_cstr
            cstr = h_cstr(i);
            
            % calculate the Jacobian
            [Jh,dJh] = calcJacobian(cstr,q,dq);
            cstr_indices = idx:idx+cstr.Dimension-1;
                    
            Je(cstr_indices,:) = Jh;
            Jedot(cstr_indices,:) = dJh; 
            idx = idx + cstr.Dimension;
        end 
    else
        Je = [];
        Jedot = [];        
    end
    
    
    
end