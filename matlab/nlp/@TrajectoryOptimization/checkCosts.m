function [yc] = checkCosts(obj, x)
    % Check the violation of the constraints 
    
    output_file = './check_cost_results.txt';
    
    f_id = fopen(output_file, 'w');
    
    
    
    
    cost_table = obj.CostTable;
    [n_node, n_cost] = size(cost_table);
    yc = zeros(1,n_cost);
    
    for j=1:n_cost
        cost_name = obj.CostTable.Properties.VariableNames{j};
        cost_array = obj.CostTable.(cost_name);
        fprintf(f_id, '***************************************\n');
        fprintf(f_id, 'Cost: %s \n', cost_name);
        for k=1:n_node         
            cost = cost_array(k);
            if cost.Dimension ~=0
                dep_constr = getSummands(cost);
                for ll = 1:numel(dep_constr)
                    dep_indices = getDepIndices(dep_constr(ll));
                    if isempty(dep_constr(ll).AuxData)
                        yc(j) = yc(j) + feval(dep_constr(ll).Funcs.Func, x(dep_indices));
                    else
                        yc(j) = yc(j) + feval(dep_constr(ll).Funcs.Func, x(dep_indices), dep_constr(ll).AuxData);
                    end
                    
                end
            end
        end
        
        fprintf(f_id, 'Value: %d \n', yc(j));
        fprintf(f_id, '***************************************\n');
        
        
    end
    

   

end