function obj = compile(obj, model, varargin)
    % Compiles the symbolic expression of kinematic functions related to
    % the domain in Mathematica
    %
    % Parameters:
    %  model: a rigid body model of type RigidBodyModel
    %  varargin: optional arguments for kinematic compile function. 
    %
    % @copydetails Kinematics::compile(obj, model, re_load)
    %
    % See also: Kinematics::compile
    
    %% kinematic constraints
    % call superclass 'compile' method first
    compile@Domain(obj, model, varargin{:});
    
    %% phase variable
    % for non time-based outputs, compile phase variable
    if ~strcmp(obj.PhaseVariable.Type, 'TimeBased')
        compile(obj.PhaseVariable.Var, model, varargin{:});
    end
   
    %% velocity output
    % if a velocity modulating output is defined
    if ~isempty(obj.ActVelocityOutput)
        % actual output
        compile(obj.ActVelocityOutput, model, varargin{:});
        
        % desired output
        [expr] = obj.getDesOutputExpr(obj.DesVelocityOutput.Type);
        
        eval_math([obj.DesVelocityOutput.Symbols.y,'=',expr,';']);
        eval_math([obj.DesVelocityOutput.Symbols.dy,'=D[',obj.DesVelocityOutput.Symbols.y,',t];']);
    end
    
    
    %% position output
    % check if position modulating outputs are defined.
    if isempty(obj.ActPositionOutput)
        error('The position modulating output is empty. Configure the output before run the compile function');
    end
    
    % actual outputs
    compile(obj.ActPositionOutput, model, varargin{:});
    % desired output
    [expr, n_param] = obj.getDesOutputExpr(obj.DesPositionOutput.Type);
    n_output = getDimension(obj.ActPositionOutput);
    eval_math([obj.DesPositionOutput.Symbols.y,'=Table[',...
        'paramsSubs=Table[a[j]->a[',num2str(n_output),'(j-1)+i],{j,1,',num2str(n_param),'}];',...
        expr,'/.paramsSubs',...
        ',{i,1,',num2str(n_output),'}',...
		'];']);
    eval_math([obj.DesPositionOutput.Symbols.dy,'=D[',obj.DesPositionOutput.Symbols.y,',t];']);
    eval_math([obj.DesPositionOutput.Symbols.ddy,'=D[',obj.DesPositionOutput.Symbols.dy,',t];']);
end
