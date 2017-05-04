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
    
    f_vec_name = obj.FvecName_;
    n_fun = length(f_vec_name);
    f_val = zeros(obj.numState,n_fun);
    if strcmp(obj.Type,'FirstOrder')        
        for i=1:n_fun
            f_val(:,i) = feval(f_vec_name{i},x);
        end
        %         f_val = cellfun(@(f)feval(f.Name,x), obj.Fvec,'UniformOutput',false);
    else
        for i=1:n_fun
            f_val(:,i) = feval(f_vec_name{i},x,dx);
        end
        %         f_val = cellfun(@(f)feval(f,x,dx), obj.Fvec,'UniformOutput',false);
    end
    
    %         f = sum([f_val{:}],2);
    f = sum(f_val,2);
end