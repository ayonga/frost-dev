function status = compileExpression(obj, model, re_load)
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
    
    
    if ~ checkFlag(model, '$ModelInitialized')
        warning(['''%s'' has NOT been initialized in Mathematica.\n',...
            'Please call initialize(model) first\n',...
            'Aborting ...\n'], model.name);
        status = false;
        return;
    end
    
    if ~ check_var_exist({obj.symbol,obj.jac_symbol,obj.jacdot_symbol}) || re_load
        
        % first compile dependent kinematics constraints
        cellfun(@(x) compileExpression(x, model), obj.kins);
        
        
        
        
        var_names = cellfun(@(kin){kin.name},obj.kins);
        
        % find symbolic varaibles in the expression
        vars = eval_math(['FindSymbols[',obj.expr,']']);
        
        % validate if symbolic variables in the expressions are members
        % of the dependent variables
        ret = eval_math(['CheckSymbols[',obj.expr,',Flatten[',cell2tensor(var_names,'ConvertString',false),']]']);
        
        if ~strcmp(ret, 'True')
            err_msg = ['Mathematica detected symbolic variables that are not defined.\n',...
                'Following symbolic variables are detected by Mathematica: \n %s'];
            
            error('Kinematics:invalidExpr',err_msg, vars);
        end
        
        
        % compute compound expression and replace symbolic
        % variables with actual expressions
        eval_math([obj.symbol,'=',obj.expr,'/.Table[v -> $h[ToString[v]], {v, ',vars,'}];']);
        
        % construct a block Mathematica code to compute Jacobian
        % using chain rule
        blk_cmd_str = [obj.jac_symbol,'=Block[{Jh,dexpr},'...
            'Jh = Table[Flatten@$Jh[ToString[v]], {v, ',vars,'}];',...
            'dexpr = D[Flatten[{',obj.expr,'}], {',vars,', 1}]/. Table[v -> First@$h[ToString[v]], {v, ',vars,'}];'...
            'dexpr.Jh];'];
        eval_math(blk_cmd_str);
        % % construct Jacobian matrix of dependent variables
        % eval_math('Jhmat = Table[Flatten@Jh[ToString[v]], {v, vars}];');
        % % compute partial derivatives and replace the symbolic
        % % variables with the actual expressions
        % eval_math('Jhexp = D[Flatten[{expr}], {Flatten[vars], 1}]/. Table[v -> First@h[ToString[v]], {v, vars}];');
        
        
        if obj.options.linearize
            % get the substitution rule for q = 0
            eval_math('{qe0subs,dqe0subs} = GetZeroStateSubs[];');
            % use chain rules to construct the final Jacobian matrix
            eval_math([obj.jac_symbol,'=',obj.jac_symbol,'/.qe0subs;']);
            % re-compute the linear function
            eval_math('Qe = GetQe[];');
            eval_math([obj.symbol,'=Flatten[',obj.jac_symbol,'.Qe];']);
        end
        
        % compute time derivatives of the Jacobian matrix
        jacdot_cmd_str = getJacDotMathCommand(obj);
        eval_math([obj.jacdot_symbol,'=',jacdot_cmd_str,';']);
        
        status = true;
    end
    
end
