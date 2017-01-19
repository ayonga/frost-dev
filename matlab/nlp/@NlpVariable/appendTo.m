function obj = appendTo(obj, vars)
    % Appends the new NlpVariable 'vars' to the existing
    % NlpVariable array
    %
    % Parameters:
    %  obj: an array of NlpVariable objects @type NlpVariable
    %  vars: a new NlpVariables to be appended to @type NlpVariable

    assert(isa(vars,'NlpVariable'),...
        'NlpVariable:incorrectDataType',...
        'The variables that append to the array must be a NlpVariable object.\n');

    last_entry = numel(obj);

    nVars = numel(vars);

    obj(last_entry+1:last_entry+nVars) = vars;

end