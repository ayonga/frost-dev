function obj = initialize(obj, nlp)
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
    assert(nlp.Options.DerivativeLevel >= 1, ...
        'IpoptApplication:DerivativeLevel',...
        ['The order of user-defined derivative functions',... 
        'must be equal or greater than 1.\n']);
    
    nlp = initializ(nlp);
    
    
    obj.Objective = array2struct(nlp.CostArray, 'Type', 'sum', 'DerivativeLevel', nlp.Options.DerivativeLevel);
    
   
    obj.Constraint = array2struct(nlp.ConstrArray, 'Type', 'list', 'DerivativeLevel', nlp.Options.DerivativeLevel);
    
    
    
   
end