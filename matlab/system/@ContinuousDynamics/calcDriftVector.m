function f = calcDriftVector(obj, q, dq)
    % calculates the drift vector Fvec(x,dx)
    %
    % Parameters:
    % x: the state variables @type colvec
    % dx: the first order derivative of state variables
    % @type colvec

       
    
    
    %|@todo This calculation is slow due to multiple function invoke.
    %Better ideas to improve the speed? 
    
    
    
    f_vec_name = obj.FvecName_;
    n_fun = numel(f_vec_name);
    f_val = zeros(obj.Dimension,n_fun);
    
    
    for i=1:n_fun
        f_val(:,i) = feval(f_vec_name{i},q,dq);
    end
        
    f = sum(f_val,2);
end