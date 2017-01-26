function obj = initialize(obj)
    % This function initialize the specific NLP application based on the
    % nonlinear programming problem (specified by 'nlp').
    %
    % The initialization including group different types of constraints,
    % index objective functions and constraints arrays, etc.
    % 
    % @see NonlinearProgram
    
    %
    % Parameters:
    %  nlp: The NLP problem to be solved @type NonlinearProgram
   
    
    % check the configuration of nlp
    assert(obj.Nlp.Options.DerivativeLevel >= 1, ...
        'IpoptApplication:DerivativeLevel',...
        ['The order of user-defined derivative functions',... 
        'must be equal or greater than 1.\n']);
    
    obj.Nlp = update(obj.Nlp);
    
    
    obj.Objective = array2struct(obj, obj.Nlp.CostArray, 'sum', obj.Nlp.Options.DerivativeLevel);
    
   
    obj.Constraint = array2struct(obj, obj.Nlp.ConstrArray, 'stack', obj.Nlp.Options.DerivativeLevel);
    
    
    
   
end