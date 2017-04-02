function [obj] = regVariable(obj, vars)
    % This method registers the information of an optimization
    % variable
    %
    % Parameters:
    %  vars: new NLP variables @type NlpVariable 
    %
    % @note We always assume ''vars'' to be a 2-D array of objects or table
    % consists of array objects. It also covers 1-D array or scalar
    % variables.
    
    
    
    
    if iscell(vars)
        % validate the class of each objects
        assert(all(cellfun(@(x)isa(x,'NlpVariable'), vars)), ...
            'Each variable must be an object of ''NlpVariable'' class');
        
        % remove empty (Dimension==0) objects from the the array
        vars = vars(~cellfun(@(x)x.Dimension==0,vars));
        % contecate to the variable array
        obj.VariableArray = [obj.VariableArray; vertcat(vars{:})];
    
    elseif isa(vars, 'NlpVariable')
        
        % remove empty (Dimension==0) objects from the the array
        vars = vars(~arrayfun(@(x)x.Dimension==0,vars));
        
        % contecate to the variable array
        obj.VariableArray = [obj.VariableArray; vars(:)];
    elseif istable(vars)
        
        % convert table content to an array
        vars = transpose(table2array(vars));
        % remove empty (Dimension==0) objects from the the array
        vars = vars(~arrayfun(@(x)x.Dimension==0,vars));
        
        % contecate to the variable array
        obj.VariableArray = [obj.VariableArray; vars(:)];
        
    else
        error('Unsupported variable type found: %s\n', class(vars));
    end
    
end