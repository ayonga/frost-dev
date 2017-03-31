function obj = setName(obj, name)
    % Specifies the name of the NLP function
    %
    % Parameters:
    % name: the name character @type char
    
    
    assert(ischar(name), 'NlpFunction:invalidNameStr', ...
        'The name must be a string.');

    % validate name string
    assert(isempty(regexp(name, '\W', 'once')),...
        'NlpFunction:invalidNameStr', ...
        'Invalid name string, can NOT contain special characters.');

    obj.Name = name;


end