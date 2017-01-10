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
    
    kins = {obj.KinGroupTable.KinObj};
    if ~ check_var_exist(struct2cell(symbols)) || re_load
        
        % first compile all kinematics constraints
        cellfun(@(x) compile(x, model, re_load), kins);
        
        % get the symbol list for the kinematic functions
        kin_symbols = cellfun(@(x) x.Symbols,kins);
        
        
        % Stack all kinematic constraints into a vector
        eval_math([symbols.Kin,'=Join[Sequence@@',...
            cell2tensor({kin_symbols.Kin},'ConvertString',false),'];']);
        
        % Stack all kinematic Jacobian into a matrix
        eval_math([symbols.Jac,'=Join[Sequence@@',...
            cell2tensor({kin_symbols.Jac},'ConvertString',false),'];']);
        
        % Stack all kinematic Jacobian into a matrix
        eval_math([symbols.JacDot,'=Join[Sequence@@',...
            cell2tensor({kin_symbols.JacDot},'ConvertString',false),'];']);
        
        
       
        
        status = true;
    end
    
end
