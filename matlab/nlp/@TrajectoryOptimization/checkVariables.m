function [xc, lb, ub] = checkVariables(obj, x)
    % Check the violation of the constraints 
    
    output_file = './check_variable_results.txt';
    
    f_id = fopen(output_file, 'w');
    
    
    
    
    var_table = obj.OptVarTable;
    [n_constr, n_node] = size(var_table);
    xc = cell(n_constr, n_node);
    lb = cell(n_constr, n_node);
    ub = cell(n_constr, n_node);
    for j=1:n_constr
        for k=1:n_node
            var = var_table{j,k}{1};
            if ~isempty(var)
                fprintf(f_id, '*************\n');
                fprintf(f_id, 'Variable: %s \t', var_table.Row{j});
                fprintf(f_id, 'Node: %d \n', k);
                fprintf(f_id, '*************\n');
                lb{j,k} = var.LowerBound;
                ub{j,k} = var.UpperBound;
                xc{j,k} = x(var.Indices);
                
                
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