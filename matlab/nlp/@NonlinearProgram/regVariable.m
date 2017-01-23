function [obj] = regVariable(obj, vars)
    % This method registers the information of an optimization
    % variable
    %
    % Parameters:
    %  vars: new NLP variables @type NlpVariable 
    %
    % @note We always assume ''vars'' to be a 2-D array or table consists
    % of cell or objects. It also covers 1-D array or scalar variables.
    
    
    if iscell(vars)
        assert(all(cellfun(@(x)isa(x,'NlpVariable'), vars(:))), ...
            'Each variable must be an object of ''NlpVariable'' class or inherited subclasses');
        
        obj.VariableArray = [obj.VariableArray; vars(:)];
    
    elseif isa(vars, 'NlpVariable')
        obj.VariableArray = [obj.VariableArray; arrayfun(@(x){x}, vars(:))];
    elseif istable(vars)
        
        tmp = table2cell(vars);
        
        assert(all(cellfun(@(x)isa(x,'NlpVariable'), tmp(:))), ...
            'Each variable must be an object of ''NlpVariable'' class or inherited subclasses');
        
        obj.VariableArray = [obj.VariableArray; tmp(:)];
        
    else
        error('Unsupported variable type found: %s\n', class(vars));
    end
    
end