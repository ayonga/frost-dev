function [yc] = checkCosts(obj, x, output_file,permission)
    % Check the value of const function 
    
    if nargin > 2    
        % print to the file
        if nargin < 4
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
    fprintf(f_id, 'Checking cost value of %s:\n', obj.Name);
    
    cost_table = obj.CostTable;
    [n_node, n_cost] = size(cost_table);
    yc = zeros(1,n_cost);
    fprintf(f_id, '**************************************************\n');
    fprintf(f_id,'%12s \t %12s\n','Cost','Value');
    
    for j=1:n_cost
        cost_name = obj.CostTable.Properties.VariableNames{j};
        cost_array = obj.CostTable.(cost_name);
        fprintf(f_id, 'Cost: %s \n', cost_name);
        for k=1:n_node         
            cost = cost_array(k);
            if cost.Dimension ~=0
                dep_constr = getSummands(cost);
                for ll = 1:numel(dep_constr)
                    dep_var = dep_constr(ll).DepVariables;
                    var = arrayfun(@(v)x(v.Indices(:)),dep_var,'UniformOutput',false); % dependent variables
                    if isempty(dep_constr(ll).AuxData)
                        yc(j) = yc(j) + feval(dep_constr(ll).Funcs.Func, var{:});
                    else
                        yc(j) = yc(j) + feval(dep_constr(ll).Funcs.Func, var{:}, dep_constr(ll).AuxData{:});
                    end
                    
                end
            end
        end
        fprintf(f_id,'%12s \t %12.8E\n',cost_name,yc(j));
    end
    fprintf(f_id, '**************************************************\n');

   
    if f_id ~= 1
        fclose(f_id);
    end
end