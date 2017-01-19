function obj = appendTo(obj, funcs)
    % Appends the new NlpFunction 'funcs' to the existing
    % NlpFunction array
    %
    % Parameters:
    %  obj: an array of NlpVariable objects @type NlpVariable
    %  funcs: a new functions to be appended to @type NlpVariable

    assert(isa(funcs,'NlpFunction'),...
        'NlpVariable:incorrectDataType',...
        'The functions that append to the array must be a NlpFunction object.\n');

    last_entry = numel(obj);

    num_funcs = numel(funcs);

    obj(last_entry+1:last_entry+num_funcs) = funcs;

end