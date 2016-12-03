function obj = setFunctionName(obj, fields, values)
    % Set the name of functions for the domain.
    %
    % The usage is similar to set/get function of
    % matlab.mixin.SetGet class, except this function does not
    % support array objects. In addition, it has input argument
    % validations specific to the current class.
    %
    % Parameters:
    %  fields: a string or cellstr of function name fields @type
    %  cellstr
    %  values: values of the field @type cellstr
    %
    % See also: matlab.mixin.SetGet
    
    valid_fields = fields(obj.funcs);
    
    if ischar(fields)
        valid_field_name = validatestring(fields,valid_fields);
        if ischar(values)
            obj.(valid_field_name) = values;
        elseif iscell(values)
            obj.(valid_field_name) = values{1};
        else
            error('The value must be a string or cell string.');
        end
    elseif iscell(fields)
        for i = 1:length(fields)
            valid_field_name = validatestring(fields,valid_fields);
            if ischar(values{i})
                obj.(valid_field_name) = values{1};
            else
                error('The value must be a string or cell string.');
            end
        end
    else
        error(['The fields must be a string or cell strings that match one of these strings:\n',...
            '%s,\t'],valid_fields);
    end
    
end
