function var_group = validateVarName(obj, name)
    % Adds unilateral (inequality) constraints on the dynamical system
    % states and inputs
    %
    % Parameters:
    %  name: the name string of the variable @type char
    
    if isfield(obj.States, name) % check if it is a state variables
        var_group = 'States';
    elseif isfield(obj.Inputs, name) % check if it is a input variables
        var_group = 'Inputs';
    elseif isfield(obj.Params, name) % check if it is a parameter variables
        var_group = 'Params';
    else
        error('The variable (%s) does not belong to any of the variable groups.', name);
    end
    
    
    
end