function obj = setType(obj, type)
    % Sets the type (either LINEAR or NONLINEAR) of the NLP function
    %
    % Parameters:
    % type: the type of the NLP function @type char
    
    % specify the function type
    if strcmpi(type, 'Linear')
        obj.Type = 'Linear';
    elseif strcmpi(type, 'Nonlinear')
        obj.Type = 'Nonlinear';
    else
        error('NlpFunction:incorrectFunctionType',...
            'Unspecified function type detected.\n');
    end
end