function [obj] = regObjective(obj, funcs)
    % This method registers the information of a NLP function as a
    % cost function
    %
    % Parameters:
    %  funcs: a list of objective functions @type NlpFunction
    %  
    % Parameters:
    %  funcs: new NLP variables @type NlpFunction 
    %
    % @note We always assume ''funcs'' to be a 2-D array or table consists
    % of cell or objects. It also covers 1-D array or scalar variables.
    %
    % @see NlpFunction
    
    
    if iscell(funcs)
        assert(all(cellfun(@(x)isa(x,'NlpFunction'), funcs(:))), ...
            'Each variable must be an object of ''NlpFunction'' class or inherited subclasses');
        
        obj.CostArray = [obj.CostArray; funcs(:)];
    
    elseif isa(funcs, 'NlpFunction')
        obj.CostArray = [obj.CostArray; arrayfun(@(x){x}, funcs(:))];
    elseif istable(funcs)
        
        % convert table content to cell array
        tmp = table2cell(funcs);
        % remove empty cells from the cell array
        tmp_new = tmp(~cellfun('isempty',tmp));
        
        assert(all(cellfun(@(x)isa(x,'NlpFunction'), tmp_new(:))), ...
            'Each variable must be an object of ''NlpFunction'' class or inherited subclasses');
        
        obj.CostArray = [obj.CostArray; tmp_new(:)];
        
    else
        error('Unsupported variable type found: %s\n', class(funcs));
    end
    
end