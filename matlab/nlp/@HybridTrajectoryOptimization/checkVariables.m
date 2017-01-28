function [xc, lb, ub] = checkVariables(obj, x)
    % Check the violation of the constraints 
    
    output_file = './check_variable_results.txt';
    
    f_id = fopen(output_file, 'w');
    
    n_phase = numel(obj.Phase);
    
    
    xc = cell(1,n_phase);
    lb = cell(1,n_phase);
    ub = cell(1,n_phase);
    
    for i=1:n_phase
        var_table = obj.Phase{i}.OptVarTable;
        [n_constr, n_node] = size(var_table);
        xc{i} = cell(n_constr, n_node);
        lb{i} = cell(n_constr, n_node);
        ub{i} = cell(n_constr, n_node);
        for j=1:n_constr
            for k=1:n_node
                var = var_table{j,k}{1};
                if ~isempty(var)
                    fprintf(f_id, '*************\n');
                    fprintf(f_id, 'Phase: %d \t', i);
                    fprintf(f_id, 'Variable: %s \t', var_table.Row{j});
                    fprintf(f_id, 'Node: %d \n', k);
                    fprintf(f_id, '*************\n');
                    lb{i}{j,k} = var.LowerBound;
                    ub{i}{j,k} = var.UpperBound;
                    xc{i}{j,k} = x(var.Indices);
                    
                    
                    fprintf(f_id,'%12s %12s %12s\n','lb','xc','ub');
                    fprintf(f_id,'%12.8E %12.8E %12.8E\r\n',[var.LowerBound, x(var.Indices), var.UpperBound]');
                    
                    if (min(x(var.Indices) - var.LowerBound)) < 0
                        fprintf(f_id,'$$ Lower bound violated: %12.8E \n',min(x(var.Indices) - var.LowerBound));
                    end
                    if (max(x(var.Indices) - var.UpperBound)) > 0
                        fprintf(f_id,'$$ Upper bound violated: %12.8E \n',max(x(var.Indices) - var.UpperBound));
                    end
                end
            end
        end
    end
    
    xc_all = cellfun(@(x)vertcat(x{:}),xc,'UniformOutput',false);
    xc = vertcat(xc_all{:});
    
    lb_all = cellfun(@(x)vertcat(x{:}),lb,'UniformOutput',false);
    lb = vertcat(lb_all{:});
    
    ub_all = cellfun(@(x)vertcat(x{:}),ub,'UniformOutput',false);
    ub = vertcat(ub_all{:});

end