function [obj] = regConstraint(obj, funcs)
    % This method registers the information of a NLP function as
    % a constraint
    %
    % Parameters:
    %  funcs: a list of contraint functions @type NlpFunction
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
        funcs = funcs(~cellfun(@(x)x.Dimension==0,funcs));
        % contecate to the variable array
        obj.ConstrArray = [obj.ConstrArray; vertcat(funcs{:})];
    
    elseif isa(funcs, 'NlpFunction')
        % remove empty (Dimension==0) objects from the the array
        funcs = funcs(~arrayfun(@(x)x.Dimension==0,funcs));
        
        % contecate to the variable array
        obj.ConstrArray = [obj.ConstrArray; funcs(:)];
    elseif istable(funcs)
        
        % convert table content to an array
        funcs = transpose(table2array(funcs));
        % remove empty (Dimension==0) objects from the the array
        funcs = funcs(~arrayfun(@(x)x.Dimension==0,funcs));
        
        % contecate to the variable array
        obj.ConstrArray = [obj.ConstrArray; funcs(:)];
        
    else
        error('Unsupported variable type found: %s\n', class(funcs));
    end
    
end