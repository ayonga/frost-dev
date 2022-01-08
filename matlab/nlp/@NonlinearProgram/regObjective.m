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
    % @note We always assume ''funcs'' to be a 2-D array of objects or
    % table consists of array objects. It also covers 1-D array or scalar
    % variables.
    %
    % @see NlpFunction
    
    
    if iscell(funcs)
        % validate the class of each objects
        assert(all(cellfun(@(x)isa(x,'NlpFunction'), funcs)), ...
            'Each variable must be an object of ''NlpFunction'' class or inherited subclasses');
        
        % remove empty (Dimension==0) objects from the the array
        funcs = funcs(~cellfun(@(x)isempty(x.Dimension),funcs));
        % contecate to the variable array
        obj.CostArray = [obj.CostArray; vertcat(funcs{:})];
    
    elseif isa(funcs, 'NlpFunction')
        % remove empty (Dimension==0) objects from the the array
        funcs = funcs(~arrayfun(@(x)isempty(x.Dimension),funcs));
        
        % contecate to the variable array
        obj.CostArray = [obj.CostArray; funcs(:)];
    elseif istable(funcs)
        
        % convert table content to an array
        funcs = transpose(table2array(funcs));
        % remove empty (Dimension==0) objects from the the array
        funcs = funcs(~arrayfun(@(x)isempty(x.Dimension),funcs));
        
        % contecate to the variable array
        obj.CostArray = [obj.CostArray; funcs(:)];
        
    else
        error('Unsupported variable type found: %s\n', class(funcs));
    end
    
end