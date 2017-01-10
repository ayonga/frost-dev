function status = compile(obj, model, re_load)
    % This function computes the symbolic expression of the
    % kinematics constraints in Mathematica.
    %
    % The compilation for KinematicExpr requires complex
    % computations, hence, we overload the superclass method here.
    %
    % Parameters:
    %  model: the rigid body model @type RigidBodyModel
    %  re_load: re-evaluate the symbolic expression @type logical
    
    if nargin < 3
        re_load = false;
    end
    
    status = true;
    
    % check valid model object
    if ~isa(model,'RigidBodyModel')
        error('Kinematics:invalidType',...
            'The model has to be an object of RigidBodyModel class.');
    end
    
    if ~ checkFlag(model, '$ModelInitialized')
        warning(['''%s'' has NOT been initialized in Mathematica.\n',...
            'Please call initialize(model) first\n',...
            'Aborting ...\n'], model.Name);
        status = false;
        return;
    end
    
    
    % validate the expression and dependence
    % extract variable names
    var_names = cellfun(@(kin){kin.Name},obj.Dependents,'UniformOutput',false);
    % validate if symbolic variables in the expressions are members
    % of the dependent variables
    if isempty(obj.Expression)
        error('The kinematic ''Expression'' is not assigned.');
    end
    ret = eval_math(['CheckSymbols[',obj.Expression,',Flatten[',cell2tensor(var_names,'ConvertString',false),']]']);
    
    if ~strcmp(ret, 'True')
        err_msg = ['Mathematica detected symbolic variables that are not defined as ''Dependents''.\n',...
            'Following symbolic variables are detected by Mathematica: \n %s'];
        
        det_var = eval_math(['FindSymbols[',obj.Expression,']']);
        
        error('Kinematics:invalidExpr',err_msg, det_var);
    end
    %%
    symbols = obj.Symbols;
    if ~ check_var_exist(struct2cell(symbols)) || re_load
        
        % first compile dependent kinematics constraints
        cellfun(@(x) compile(x, model, re_load), obj.Dependents);
        
        var_names = cellfun(@(kin){kin.Name},obj.Dependents);
        
        % find symbolic varaibles in the expression
        vars = eval_math(['FindSymbols[',obj.Expression,']']);
        
        % validate if symbolic variables in the expressions are members
        % of the dependent variables
        ret = eval_math(['CheckSymbols[',obj.Expression,',Flatten[',cell2tensor(var_names,'ConvertString',false),']]']);
        
        if ~strcmp(ret, 'True')
            err_msg = ['Mathematica detected symbolic variables that are not defined.\n',...
                'Following symbolic variables are detected by Mathematica: \n %s'];
            
            error('Kinematics:invalidExpr',err_msg, vars);
        end
        
        
        % compute compound expression and replace symbolic
        % variables with actual expressions
        eval_math([symbols.Kin,'=',obj.Expression,'/.Table[v -> $h[ToString[v]], {v, ',vars,'}];']);
        
        % construct a block Mathematica code to compute Jacobian
        % using chain rule
        blk_cmd_str = [symbols.Jac,'=Block[{Jh,dexpr},'...
            'Jh = Table[Flatten@$Jh[ToString[v]], {v, ',vars,'}];',...
            'dexpr = D[Flatten[{',obj.Expression,'}], {',vars,', 1}]/. Table[v -> First@$h[ToString[v]], {v, ',vars,'}];'...
            'dexpr.Jh];'];
        eval_math(blk_cmd_str);
        % % construct Jacobian matrix of dependent variables
        % eval_math('Jhmat = Table[Flatten@Jh[ToString[v]], {v, vars}];');
        % % compute partial derivatives and replace the symbolic
        % % variables with the actual expressions
        % eval_math('Jhexp = D[Flatten[{expr}], {Flatten[vars], 1}]/. Table[v -> First@h[ToString[v]], {v, vars}];');
        
        
        if obj.Linearize
            % get the substitution rule for q = 0
            eval_math('{qe0subs,dqe0subs} = GetZeroStateSubs[];');
            % use chain rules to construct the final Jacobian matrix
            eval_math([symbols.Jac,'=',symbols.Jac,'/.qe0subs;']);
            % re-compute the linear function
            eval_math('Qe = GetQe[];');
            eval_math([symbols.Kin,'=Flatten[',symbols.Jac,'.Qe];']);
        end
        
        % compute time derivatives of the Jacobian matrix
        jacdot_cmd_str = getJacDotMathCommand(obj);
        eval_math([symbols.JacDot,'=',jacdot_cmd_str,';']);
        
        status = true;
    end
    
end
