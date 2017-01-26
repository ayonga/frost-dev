function obj = setFuncs(obj, funcs)
    % This function specify the functions (name) that calculates the
    % the function
    %
    % Parameters:
    % funcs: 
    %
    % Required fields of Funcs:
    %   Func: a string of the function that computes the
    %   function value @type char
    %   Jac: a string of the function that computes the
    %   function Jacobian @type char
    %   JacStruct: a string of the function that computes the
    %   sparsity structure of function Jacobian @type char
    %   Hess: a string of the function that computes the
    %   function Hessian @type char
    %   HessStruct: a string of the function that computes the
    %   sparsity structure of function Hessian @type char
    % @type struct

    assert(isstruct(funcs),...
        'The input argument must be a struct.');
    
    assert(all(isfield(funcs, {'Func', 'Jac', 'JacStruct', 'Hess', 'HessStruct'})),...
        ['Required fields missing. \n',...
        'Following fields must be present: %s'], ...
        implode({'Func', 'Jac', 'JacStruct', 'Hess', 'HessStruct'},', '));
    
    obj.Funcs = funcs;

    

end