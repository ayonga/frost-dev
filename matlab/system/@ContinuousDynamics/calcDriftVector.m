function f = calcDriftVector(obj, x, dx)
    % calculates the mass matrix Fvec(x) or Fvec(x,dx)
    %
    % Parameters:
    % x: the state variables @type colvec
    % dx: the first order derivative of state variables
    % @type colvec

    %     validateattributes(x, {'double'},...
    %         {'vector','numel',obj.numState,'real'},...
    %         'ContinuousDynamics.calcDriftVector','x');
    %     validateattributes(dx, {'double'},...
    %         {'vector','numel',obj.numState,'real'},...
    %         'ContinuousDynamics.calcDriftVector','dx');
    %     Ce = -Ce_mat(x,dx);
    %     Ge = -Ge_vec(x);
    %     f = Ce*dx + Ge;
    
    
    %|@todo This calculation is slow due to multiple function invoke.
    %Better ideas to improve the speed? 
    f_vec_name = obj.FvecName_;
    n_fun = length(f_vec_name);
    f_val = zeros(obj.numState,n_fun);
    if strcmp(obj.Type,'FirstOrder')        
        for i=1:n_fun
            f_val(:,i) = feval(f_vec_name{i},x);
        end
    else
        for i=1:n_fun
            f_val(:,i) = feval(f_vec_name{i},x,dx);
        end
    end
    
    f = sum(f_val,2);
end