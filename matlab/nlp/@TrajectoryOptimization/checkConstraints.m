function [yc, cl, cu] = checkConstraints(obj, x, tol, output_file, permission)
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
    fprintf(f_id, 'Checking constraint violation of %s:\n', obj.Name);
    
    
    constr_table = obj.ConstrTable;
    [n_node, n_constr] = size(constr_table);
    yc = cell(n_constr, n_node);
    cl = cell(n_constr, n_node);
    cu = cell(n_constr, n_node);
    
    for j=1:n_constr
        constr_name = obj.ConstrTable.Properties.VariableNames{j};
        constr_array = obj.ConstrTable.(constr_name);
        for k=1:n_node         
            constr = constr_array(k);
            if constr.Dimension ~=0
                fprintf(f_id, '******************************************************************************\n');
                fprintf(f_id, 'Domain: %s \t', obj.Name);
                fprintf(f_id, 'Constraint: %s \t', constr_name);
                fprintf(f_id, 'Node: %d \n', k);
                fprintf(f_id, '------------------------------------------------------------------------------\n');
                dep_constr = getSummands(constr);
                cl{j,k} = constr.LowerBound;
                cu{j,k} = constr.UpperBound;
                yc_ll = zeros(constr.Dimension,1);
                for ll = 1:numel(dep_constr)
                    dep_var = dep_constr(ll).DepVariables;
                    var = arrayfun(@(v)x(v.Indices(:)),dep_var,'UniformOutput',false); % dependent variables
                    if isempty(dep_constr(ll).AuxData)
                        yc_ll = yc_ll + feval(dep_constr(ll).Funcs.Func, var{:});
                    else
                        yc_ll = yc_ll + feval(dep_constr(ll).Funcs.Func, var{:}, dep_constr(ll).AuxData{:});
                    end
                    
                end
                
                yc{j,k} = yc_ll;
                fprintf(f_id,'%12s %12s %12s\n','Lower','Constraint','Upper');
                fprintf(f_id,'%12.8E %12.8E %12.8E\r\n',[constr.LowerBound, yc_ll, constr.UpperBound]');
                
                if (min(yc_ll - constr.LowerBound)) < -tol
                    fprintf(f_id,'$$ Lower bound violated: %12.8E \n',min(yc_ll - constr.LowerBound));
                end
                if (max(yc_ll - constr.UpperBound)) > tol
                    fprintf(f_id,'$$ Upper bound violated: %12.8E \n',max(yc_ll - constr.UpperBound));
                end
            end
        end
    end
    
    yc = vertcat(yc{:});
    cl = vertcat(cl{:});
    cu = vertcat(cu{:});
    
    fprintf(f_id, '**************************************************\n');
    if f_id ~= 1
        fclose(f_id);
    end

end