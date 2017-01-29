function [calcs, params] = exportSolution(obj, sol)
    % Analyzes the solution of the NLP problem
    %
    % Parameters:
    % sol: The solution vector of the NLP problem @type colvec
    
    
    n_phase = length(obj.Phase);
    
    calcs = cell(n_phase,1);
    params = cell(n_phase,1);
   
    t0 = 0;
    for j = 1:n_phase
        cur_phase = obj.Phase{j};
        var_table = obj.Phase{j}.OptVarTable;
        cur_domain = obj.Gamma.Nodes.Domain{cur_phase.CurrentVertex};
        T = sol(var_table{'T',1}{1}.Indices);
        switch obj.Options.CollocationScheme
            case 'HermiteSimpson'
                tspan = t0:T/(cur_phase.NumNode-1):(t0+T);
                calcs{j}.t = tspan;
                t0 = t0 + T;
            case 'Trapezoidal'
                tspan = t0:T/(cur_phase.NumNode-1):(t0+T);
                calcs{j}.t = tspan;
                t0 = t0 + T;
                
            otherwise
                error('Undefined integration scheme.');
        end
        B  = cur_domain.ActuationMap;
        for i=1:cur_phase.NumNode
            calcs{j}.qe(:,i)  = sol(var_table{'Qe',i}{1}.Indices);
            calcs{j}.dqe(:,i)  = sol(var_table{'dQe',i}{1}.Indices);
            calcs{j}.ddqe(:,i) = sol(var_table{'ddQe',i}{1}.Indices);
            
            calcs{j}.uq(:,i)   = B*sol(var_table{'U',i}{1}.Indices);
            calcs{j}.Fe(:,i)  = sol(var_table{'Fe',i}{1}.Indices);
            
        end
        calcs{j}.h  = sol(var_table{'H',1}{1}.Indices);
        if obj.Options.EnableVirtualConstraint
            a_vec = sol(var_table{'A',1}{1}.Indices);            
            n_param = cur_domain.DesPositionOutput.NumParam;
            n_output = getDimension(cur_domain.ActPositionOutput);
            a_mat = reshape(a_vec,n_param,n_output);
            params{j}.a = a_mat';
            params{j}.p = sol(var_table{'P',1}{1}.Indices);
            if ~isempty(cur_domain.ActVelocityOutput)
                params{j}.v = sol(var_table{'V',1}{1}.Indices);
            end
        end
       
            
        
    end
    
    
    
    
end