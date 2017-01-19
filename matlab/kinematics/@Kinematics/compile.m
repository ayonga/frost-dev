function status = compile(obj, model, re_load)
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
    symbols = obj.Symbols;
    if ~ check_var_exist(struct2cell(symbols)) || re_load
        % compile symbolic expressions
        
        kin_cmd_str = getKinMathCommand(obj, model);
        jac_cmd_str = getJacMathCommand(obj, model);
        jacdot_cmd_str = getJacDotMathCommand(obj);
        if obj.Linearize
            
            % first obtain the symbolic expression for the
            % kinematic function
            eval_math([symbols.Kin,'=',kin_cmd_str,';']);
            
            % get the substitution rule for q = 0
            eval_math('{qe0subs,dqe0subs} = GetZeroStateSubs[];');
            
            % compute the Jacobian at q = 0
            eval_math([symbols.Jac,'=',jac_cmd_str,'/.qe0subs;']);
            % re-compute the linear function
            eval_math('Qe = GetQe[];');
            eval_math([symbols.Kin,'=Flatten[',symbols.Jac,'.Qe];']);
            
            eval_math([symbols.JacDot,'=',jacdot_cmd_str,';']);
        else
            eval_math([symbols.Kin,'=',kin_cmd_str,';']);
            eval_math([symbols.Jac,'=',jac_cmd_str,';']);
            eval_math([symbols.JacDot,'=',jacdot_cmd_str,';']);
        end
        
        
        status = true;
    end
end
