function obj = configure(obj, derivative_level)
    % Configures the function handles and sparsity patterns of function
    % derivatives
    %
    %
    % Parameters:
    %  derivative_level: determines the level of derivatives to be exported
    %  (1, 2) @type double
    
    
    if nargin < 2
        derivative_level = 1;
    end
    

    if derivative_level == 1
        obj = setFunctionName(obj, ['f_', obj.Name]);
        
        js = feval(['Js_', obj.Name],0);
        obj = setJacobianPattern(obj,js,'IndexForm');
        obj = setJacobianFunction(obj,['J_', obj.Name]);
        
    elseif derivative_level == 2
        obj = setFunctionName(obj, ['f_', obj.Name]);
        
        js = feval(['Js_', obj.Name],0);
        obj = setJacobianPattern(obj,js,'IndexForm');
        obj = setJacobianFunction(obj,['J_', obj.Name]);
        
        hs = feval(['Hs_', obj.Name],0);
        obj = setJacobianPattern(obj,hs,'IndexForm');
        obj = setJacobianFunction(obj,['H_', obj.Name]);
    end
end