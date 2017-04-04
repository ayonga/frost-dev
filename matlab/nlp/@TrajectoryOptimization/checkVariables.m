function [xc, lb, ub] = checkVariables(obj, x)
    % Check the violation of the constraints 
    
    output_file = './check_variable_results.txt';
    
    f_id = fopen(output_file, 'w');
    
    
    
    
    var_table = obj.OptVarTable;
    [n_node,n_var] = size(var_table);
    xc = cell(n_var, n_node);
    lb = cell(n_var, n_node);
    ub = cell(n_var, n_node);
    for j=1:n_var
        var_name = obj.OptVarTable.Properties.VariableNames{j};
        var_array = obj.OptVarTable.(var_name);
        for k=1:n_node
            var = var_array(k);
            if ~isempty(var)
                fprintf(f_id, '*************\n');
                fprintf(f_id, 'Variable: %s \t', var_name);
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