function s = setfields(s, field_names, values, cond)
    % Set the name of functions for the domain.
    %
    % The usage is similar to set/get function of
    % matlab.mixin.SetGet class.
    %
    % @author ayonga @date 2016-12-01
    %
    % Parameters:
    %  s: a structure of type struct
    %  fields: a string or cellstr of structure fields @type
    %  cellstr
    %  values: fields values @type cellstr
    %  cond: a validating condition for values @type function_handle
    %
    % See also: matlab.mixin.SetGet
    
    if nargin < 4
        cond = @(x)true;
    end
    
    assert(isstruct(s));
    
    valid_fields = fields(s);
    
    if ischar(field_names) 
        field_names = {field_names};
        values = {values};
    end
    
    
    for i = 1:length(field_names)
        if any(validatestring(field_names,valid_fields))
            if feval(cond, values{i})
                s.(field_names{i}) = values{i};
            else
                error('Invalid values.');
            end
        else
            error(['The fields must be a string or cell strings that match one of these strings:\n',...
                '%s,\t'],valid_fields);
        end
    end
    
    
    
end
