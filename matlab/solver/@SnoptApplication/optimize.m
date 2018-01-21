function [sol, info] = optimize(obj, x0)
    % This function runs the solver's optimization routine for the
    % NLP
    %
    % Be sure the run the initialization procedure before run this
    % function.
    
    nlp = obj.Nlp;
    
    % get the information of NLP variables 
    [dimVars, xlow, xupp] = getVarInfo(nlp);
    xmul = 0 * xlow;
    xstate = 0*xlow;
    
    % Get constraint information
    clow = vertcat(obj.Constraint.LowerBound);
    cupp = vertcat(obj.Constraint.UpperBound);
    cmul = 0*clow;
    cstate = 0*clow;
    
    olow = -inf;
    oupp = inf;
    omul = 0;
    ostate = 0;
    
    Flow = [clow; olow];
    Fupp = [cupp; oupp];
    Fmul = [cmul; omul];
    Fstate = [cstate; ostate];
    
    % get the initial guess 
    if nargin < 2
        x0 = getInitialGuess(nlp, obj.Options.initialguess);
    end
    
    opts = struct();
    opts = obj.Options.snopt;
    
    snscreen on;

    % Create stacked objective and constraint
    userfun = @(x) userFunc(x, obj.Objective, obj.Constraint, dimVars, obj.Options.UseMexSparse);
    
    [~, ~, Objrow] = userFunc(x0, obj.Objective, obj.Constraint, dimVars, obj.Options.UseMexSparse);
    
    gradientStructure = @()SnoptGradientStructure(obj.Objective, dimVars, obj.Options.UseMexSparse);
    jacobianStructure = @()SnoptJacobianStructure(obj.Constraint, dimVars, obj.Options.UseMexSparse);
    J = [jacobianStructure();gradientStructure()];
    [iJ, jJ] = find(J);
        
    [sol, info] = snopt( x0, xlow, xupp, xmul, xstate, ...
                         Flow, Fupp, Fmul, Fstate, ...
                         userfun, [], Objrow, [], [], [], ...
                         iJ, jJ, opts );

end    

%% Evaluate the user functions and jacobians

function [F, J, Objrow] = userFunc(x, objective, constraint, dimVars, use_mex)
    % Establish the functions and their jacobians
    [Fobj, Jobj] = objectiveFun(x, objective, dimVars, use_mex);
    [Fcon, ~, Jcon] = constraintFun(x, constraint, dimVars, use_mex);
    
    F = [Fcon; Fobj];
    J = [Jcon; Jobj];
    drawnow;
    % Specify which are correspond to the objective function
    Objrow = length(Fcon) + 1;    
end

function [F, J] = objectiveFun(x, objective, dimVars, use_mex)
    F = SnoptObjective(x, objective);
    J = SnoptGradient(x, objective, dimVars, use_mex);
end

function [C, ceq, J, Dceq] = constraintFun(x, constraint, dimVars, use_mex)
    C = SnoptConstraints(x, constraint);
    J = SnoptJacobian(x, constraint, dimVars, use_mex);
    
    ceq = [];
    Dceq = [];
end
    
    %% objective function
    function f = SnoptObjective(x, objective)
        % nested function that commputes the objective function of the
        % NLP problem
        %
        % Parameters:
        %  objective: a structure of arrays that contains the information
        %  of all subfunction of the objective.
        
        f = zeros(objective.Dimension,1);
        for i = 1:objective.numFuncs
            var = cellfun(@(v)x(v(:)),objective.DepIndices{i},'UniformOutput',false); % dependent variables
            %cellfun(@(x)a(x{:}]),ind)
            % calculate cost value
            if isempty(objective.AuxData{i})
                f(objective.FuncIndices{i}) = f(objective.FuncIndices{i}) + feval(objective.Funcs{i}, var{:});
            else
                f(objective.FuncIndices{i}) = f(objective.FuncIndices{i}) + feval(objective.Funcs{i}, var{:}, objective.AuxData{i}{:});
            end
            
        end
    end
    %%
    
    
    %% constraints
    function [C] = SnoptConstraints(x, constraint)
        % nested function that commputes the constraints of the NLP problem
        %
        % Parameters:
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        
        
        % preallocation
        C   = zeros(constraint.Dimension,1);
        for i = 1:constraint.numFuncs
            var = cellfun(@(v)x(v(:)),constraint.DepIndices{i},'UniformOutput',false); % dependent variables
            
            % calculate constraints
            if isempty(constraint.AuxData{i})
                C(constraint.FuncIndices{i}) = C(constraint.FuncIndices{i}) + feval(constraint.Funcs{i}, var{:});
            else
                C(constraint.FuncIndices{i})  = C(constraint.FuncIndices{i}) + feval(constraint.Funcs{i}, var{:}, constraint.AuxData{i}{:});
            end
        end
        
    end
    %%
    
    %% Objective gradient function
    function [J] = SnoptGradient(x, objective, dimVars, use_mex)
        % nested function that commputes the first-order derivatives
        % (gradient) of the objective function of the NLP problem
        %
        % Parameters:
        %  objective: a structure of arrays that contains the information
        %  of all subfunction of the objective.
        %  dimVars: the dimension of the NLP variables
        %  use_mex: indicates to use mex version of ''sparse'' function 
        %  @type logical
        
        
        
        % preallocation
        J_val   = zeros(objective.nnzJac,1);
        for i = 1:objective.numFuncs
            var = cellfun(@(v)x(v(:)),objective.DepIndices{i},'UniformOutput',false); % dependent variables
            
            % calculate gradient
            if isempty(objective.AuxData{i})
                J_val(objective.nzJacIndices{i}) = feval(objective.JacFuncs{i}, var{:});
            else
                J_val(objective.nzJacIndices{i}) = feval(objective.JacFuncs{i}, var{:}, objective.AuxData{i}{:});
            end
            
        end
        
        % construct the sparse jacobian matrix
        if use_mex
            J = sparse2(objective.nzJacRows, objective.nzJacCols,...
                J_val, 1, dimVars, objective.nnzJac);
        else
            J = sparse(objective.nzJacRows, objective.nzJacCols,...
                J_val, 1, dimVars, objective.nnzJac);
        end
    end
    
    %% objective Gradient structure
    function [J] = SnoptGradientStructure(objective, dimVars, use_mex)
        % nested function that commputes the sparsity structure of the
        % first-order derivatives (Jacobian) of the constraints of the NLP
        % problem
        %
        % Parameters:
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        %  use_mex: indicates to use mex version of ''sparse'' function 
        %  @type logical
        
        if use_mex
            J = sparse2(objective.nzJacRows, objective.nzJacCols,...
                ones(objective.nnzJac,1), 1, ...
                dimVars, objective.nnzJac);
        else
            J = sparse(objective.nzJacRows, objective.nzJacCols,...
                ones(objective.nnzJac,1), 1, ...
                dimVars, objective.nnzJac);
        
        end
    end
    %% constraints Jacobian
    function [J] = SnoptJacobian(x, constraint, dimVars, use_mex)
        % nested function that commputes the first-order derivatives
        % (Jacobian) of the constraints of the NLP problem
        %
        % Parameters:
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        %  use_mex: indicates to use mex version of ''sparse'' function 
        %  @type logical
        
        % preallocation
        J_val   = zeros(constraint.nnzJac,1);
        for i = 1:constraint.numFuncs
            var = cellfun(@(v)x(v(:)),constraint.DepIndices{i},'UniformOutput',false); % dependent variables
            
            % calculate Jacobian
            if isempty(constraint.AuxData{i})
                J_val(constraint.nzJacIndices{i}) = feval(constraint.JacFuncs{i}, var{:});
            else
                J_val(constraint.nzJacIndices{i}) = feval(constraint.JacFuncs{i}, var{:}, constraint.AuxData{i}{:});
            end
            
        end
        
        % construct the sparse jacobian matrix
        if use_mex
            J = sparse2(constraint.nzJacRows, constraint.nzJacCols,...
                J_val, constraint.Dimension, dimVars, constraint.nnzJac);
        else
            J = sparse(constraint.nzJacRows, constraint.nzJacCols,...
                J_val, constraint.Dimension, dimVars, constraint.nnzJac);
        end
    end
    %%
    
    %% constraints Jacobian structure
    function [J] = SnoptJacobianStructure(constraint, dimVars, use_mex)
        % nested function that commputes the sparsity structure of the
        % first-order derivatives (Jacobian) of the constraints of the NLP
        % problem
        %
        % Parameters:
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        %  use_mex: indicates to use mex version of ''sparse'' function 
        %  @type logical
        
        if use_mex
            J = sparse2(constraint.nzJacRows, constraint.nzJacCols,...
                ones(constraint.nnzJac,1), constraint.Dimension, ...
                dimVars, constraint.nnzJac);
        else
            J = sparse(constraint.nzJacRows, constraint.nzJacCols,...
                ones(constraint.nnzJac,1), constraint.Dimension, ...
                dimVars, constraint.nnzJac);
        
        end
    end
    %%
    
    %% Hessian
    function [H_ret] = SnoptHessian(x, sigma, lambda, ...
            objective, constraint, dimVars, use_mex)
        % nested function that commputes the second-order derivatives
        % (Hessian) of the Lagrangian of the NLP problem
        %
        % Parameters:
        %  objective: a structure of arrays that contains the information
        %  of all subfunction of the objective.
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        %  use_mex: indicates to use mex version of ''sparse'' function 
        %  @type logical
        
        
        
        % preallocation
        hes_objective   = zeros(objective.nnzHess,1);
        
        % compute the Hessian for objective function
        for i = 1:objective.numFuncs
            var = cellfun(@(v)x(v(:)),objective.DepIndices{i},'UniformOutput',false); % dependent variables
            
            if ~isempty(objective.nzHessIndices{i})
                % if the function is a linear function, then the Hessian of
                % such function is zero. In other words, the non-zero
                % indices should be empty.
                if isempty(objective.AuxData{i})
                    hes_objective(objective.nzHessIndices{i}) = feval(objective.hess_Funcs{i}, var{:}, sigma);
                else
                    hes_objective(objective.nzHessIndices{i}) = feval(objective.hess_Funcs{i}, var{:}, sigma, objective.AuxData{i}{:});
                end
            end
            
        end
        if use_mex
            H_objective = sparse2(objective.nzHessRows,objective.nzHessRows,...
                hes_objective, dimVars, dimVars, objective.nnzHess);
        else
            H_objective = sparse(objective.nzHessRows,objective.nzHessRows,...
                hes_objective, dimVars, dimVars, objective.nnzHess);
        end
        % preallocation
        hes_constr   = zeros(constraint.nnzHess,1);
        % compute the Hessian for constraints
        for i = 1:constraint.numFuncs
            var = cellfun(@(v)x(v(:)),constraint.DepIndices{i},'UniformOutput',false); % dependent variables
            lambda_i = lambda(constraint.FuncIndices{i});
            
            if ~isempty(constraint.nzHessIndices{i})
                % if the function is a linear function, then the Hessian of
                % such function is zero. In other words, the non-zero
                % indices should be empty.
                if isempty(constraint.AuxData{i})
                    hes_constr(constraint.nzHessIndices{i}) = feval(constraint.hess_Funcs{i}, var{:}, lambda_i);
                else
                    hes_constr(constraint.nzHessIndices{i}) = feval(constraint.hess_Funcs{i}, var{:}, lambda_i, constraint.AuxData{i}{:});
                end
            end
            
        end
        
          
        if use_mex
            H_constr = sparse2(constraint.nzHessRows,constraint.nzHessRows,...
                hes_constr, dimVars, dimVars, constraint.nnzHess);
        else
            H_constr = sparse(constraint.nzHessRows,constraint.nzHessRows,...
                hes_constr, dimVars, dimVars, constraint.nnzHess);
        end
        
        H_ret = H_objective + H_constr;
    end
    %%
    
    %%
    function [H_ret] = SnoptHessianStructure(objective, constraint, dimVars, use_mex)
        % nested function that returns the sparsity structure of the
        % second-order derivatives (Hessian) of the Lagrangian of the NLP
        % problem
        %
        % Parameters:
        %  objective: a structure of arrays that contains the information
        %  of all subfunction of the objective.
        %  constraint: a structure of arrays that contains the information
        %  of all constraints
        %  dimVars: the dimension of the NLP variables
        %  use_mex: indicates to use mex version of ''sparse'' function 
        %  @type logical
        
        if use_mex
            H_objective = sparse2(objective.nzHessRows,objective.nzHessRows,...
                ones(objective.nnzHess,1), dimVars, dimVars, objective.nnzHess);
            
            
            H_constr = sparse2(constraint.nzHessRows,constraint.nzHessRows,...
                ones(constraint.nnzHess,1), dimVars, dimVars, constraint.nnzHess);
        else
            H_objective = sparse(objective.nzHessRows,objective.nzHessRows,...
                ones(objective.nnzHess,1), dimVars, dimVars, objective.nnzHess);
            
            
            H_constr = sparse(constraint.nzHessRows,constraint.nzHessRows,...
                ones(constraint.nnzHess,1), dimVars, dimVars, constraint.nnzHess);
        end
        
        H_ret = H_objective + H_constr;
        
    end
