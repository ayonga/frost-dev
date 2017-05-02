function checkVariables(obj, x, tol, output_file, permission)
    % Check the violation of the constraints 
    
    if nargin < 3
        tol = 1e-3;
    end
    
    if nargin > 3    
        % print to the file
        if nargin < 5
            permission = 'w';
        else
            validatestring(permission, {'a','w'});
        end
        f_id = fopen(output_file, permission);
    else
        % print on the screen 
        f_id = 1;
    end
    
    fprintf(f_id, '**************************************************\n');
    fprintf(f_id, 'Checking variable violation of %s:\n', obj.Name);
    
    
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
                fprintf(f_id, '***************************************\n');
                fprintf(f_id, 'Variable: %s \t', var_name);
                fprintf(f_id, 'Node: %d \n', k);
                fprintf(f_id, '---------------------------------------\n');
                lb{j,k} = var.LowerBound;
                ub{j,k} = var.UpperBound;
                xc{j,k} = x(var.Indices);
                
                
                fprintf(f_id,'%12s %12s %12s\n','Lower','Variable','Upper');
                fprintf(f_id,'%12.8E %12.8E %12.8E\r\n',[var.LowerBound, x(var.Indices), var.UpperBound]');
                
                if (min(x(var.Indices) - var.LowerBound)) < -tol
                    fprintf(f_id,'$$ Lower bound violated: %12.8E \n',min(x(var.Indices) - var.LowerBound));
                end
                if (max(x(var.Indices) - var.UpperBound)) > tol
                    fprintf(f_id,'$$ Upper bound violated: %12.8E \n',max(x(var.Indices) - var.UpperBound));
                end
            end
        end
    end
    
    fprintf(f_id, '**************************************************\n');
    
    if f_id ~= 1
        fclose(f_id);
    end
    

end