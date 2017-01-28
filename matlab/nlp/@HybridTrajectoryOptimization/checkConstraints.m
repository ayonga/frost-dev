function [yc, cl, cu] = checkConstraints(obj, x)
    % Check the violation of the constraints 
    
    output_file = './check_constr_results.txt';
    
    f_id = fopen(output_file, 'w');
    
    n_phase = numel(obj.Phase);
    
    
    yc = cell(1,n_phase);
    cl = cell(1,n_phase);
    cu = cell(1,n_phase);
    
    for i=1:n_phase
        constr_table = obj.Phase{i}.ConstrTable;
        [n_constr, n_node] = size(constr_table);
        yc{i} = cell(n_constr, n_node);
        cl{i} = cell(n_constr, n_node);
        cu{i} = cell(n_constr, n_node);
        for j=1:n_constr
            for k=1:n_node
                constr = constr_table{j,k}{1};
                if ~isempty(constr)
                    fprintf(f_id, '*************\n');
                    fprintf(f_id, 'Phase: %d \t', i);
                    fprintf(f_id, 'Constraint: %s \t', constr_table.Row{j});
                    fprintf(f_id, 'Node: %d \n', k);
                    fprintf(f_id, '*************\n');
                    dep_constr = getDepObject(constr);
                    cl{i}{j,k} = constr.LowerBound;
                    cu{i}{j,k} = constr.UpperBound;
                    yc_ll = zeros(constr.Dimension,1);
                    for ll = 1:numel(dep_constr)
                        dep_indices_cell = getDepIndices(dep_constr{ll});
                        dep_indices = vertcat(dep_indices_cell{:});
                        if isempty(dep_constr{ll}.AuxData)
                            yc_ll = yc_ll + feval(dep_constr{ll}.Funcs.Func, x(dep_indices));
                        else
                            yc_ll = yc_ll + feval(dep_constr{ll}.Funcs.Func, x(dep_indices), dep_constr{ll}.AuxData);
                        end
                        
                    end
                    
                    yc{i}{j,k} = yc_ll;
                    fprintf(f_id,'%12s %12s %12s\n','cl','yc','cu');
                    fprintf(f_id,'%12.8E %12.8E %12.8E\r\n',[constr.LowerBound, yc_ll, constr.UpperBound]');
                    
                    if (min(yc_ll - constr.LowerBound)) < 0
                        fprintf(f_id,'$$ Lower bound violated: %12.8E \n',min(yc_ll - constr.LowerBound));
                    end
                    if (max(yc_ll - constr.UpperBound)) > 0
                        fprintf(f_id,'$$ Upper bound violated: %12.8E \n',max(yc_ll - constr.UpperBound));
                    end
                end
            end
        end
    end

    yc_all = cellfun(@(x)vertcat(x{:}),yc,'UniformOutput',false);
    yc = vertcat(yc_all{:});
    
    cl_all = cellfun(@(x)vertcat(x{:}),cl,'UniformOutput',false);
    cl = vertcat(cl_all{:});
    
    cu_all = cellfun(@(x)vertcat(x{:}),cu,'UniformOutput',false);
    cu = vertcat(cu_all{:});

end