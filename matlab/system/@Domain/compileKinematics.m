function obj = compileKinematics(obj, model, varargin)
    % Compiles the symbolic expression of kinematic functions related to
    % the domain in Mathematica
    %
    % Parameters:
    %  model: a rigid body model of type RigidBodyModel
    %  varargin: optional arguments for kinematic compile function. 
    %
    % @copydetails Kinematics::compileExpression(obj, model, re_load)
    %
    % See also: Kinematics::compileExpression
    
    
    flag = '$ModelInitialized';
    if ~checkFlag(model, flag)
        warning('The robot model has NOT been initialized in Mathematica.\n');
        warning('Please call initialize(robot) first\n');
        warning('Aborting ...\n');
        return;
    end
    
    
    % first compile all kinematics constraints defined for the
    % domain to create symbolic expressions
    % holonomic constraints
    cellfun(@(x)compileExpression(x, model, varargin{:}), obj.HolonomicConstr);
    
    
    % get the symbol list for the kinematic functions
    kin_symbols = cellfun(@(x) x.Symbols,obj.HolonomicConstr);
    
    hol_symbols = obj.HolSymbols;
    % Stack all kinematic constraints into a vector
    eval_math([hol_symbols.Kin,'=Join[Sequence@@',...
        cell2tensor({kin_symbols.Kin},'ConvertString',false),'];']);
    
    % Stack all kinematic Jacobian into a matrix
    eval_math([hol_symbols.Jac,'=Join[Sequence@@',...
        cell2tensor({kin_symbols.Jac},'ConvertString',false),'];']);
    
    % Stack all kinematic Jacobian into a matrix
    eval_math([hol_symbols.JacDot,'=Join[Sequence@@',...
        cell2tensor({kin_symbols.JacDot},'ConvertString',false),'];']);
    
    % % check the size of the symbolic expression
    % hol_constr_size = math('math2matlab',['Dimensions[',hol_symbols.Kin,']']);
    % assert(obj.DimensionHolonomic == hol_constr_size, ...
    %     'Domain:invalidsize',...
    %     ['The dimension of the holonomic constraint expression is %d.\',...
    %     'It should be %d.'],hol_constr_size,obj.n_hol_constr);
    
    
    
    
    % kinematic type of unilateral constraints
    kin_unilateral = obj.UnilateralConstr{strcmp('Kinematic',obj.UnilateralConstr.Type),'KinObject'};
    if ~isempty(kin_unilateral)        
        cellfun(@(x)compileExpression(x, model, varargin{:}), kin_unilateral);
    end
    
end
