function status = compileExpression(obj, model, re_load)
    % This function computes the symbolic expression of the
    % kinematics constraints in Mathematica.
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
        % compile symbolic expressions
        
        kin_cmd_str = getKinMathCommand(obj);
        jac_cmd_str = getJacMathCommand(obj);
        jacdot_cmd_str = getJacDotMathCommand(obj);
        if obj.options.linearize
            
            % first obtain the symbolic expression for the
            % kinematic function
            eval_math([obj.symbol,'=',kin_cmd_str,';']);
            
            % get the substitution rule for q = 0
            eval_math('{qe0subs,dqe0subs} = GetZeroStateSubs[];');
            
            % compute the Jacobian at q = 0
            eval_math([obj.jac_symbol,'=',jac_cmd_str,'/.qe0subs;']);
            
            % re-compute the linear function
            eval_math('Qe = GetQe[];');
            eval_math([obj.symbol,'=Flatten[',obj.jac_symbol,'.Qe];']);
            
            eval_math([obj.jacdot_symbol,'=',jacdot_cmd_str,';']);
        else
            eval_math([obj.symbol,'=',kin_cmd_str,';']);
            eval_math([obj.jac_symbol,'=',jac_cmd_str,';']);
            eval_math([obj.jacdot_symbol,'=',jacdot_cmd_str,';']);
        end
        
        
        status = true;
    end
end
