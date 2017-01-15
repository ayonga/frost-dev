function value = calcUnilateralCondition(obj, cond, model, qe, dqe, u)
    % Calculates the unilateral condition specified by ''cond''
    %
    % Use the syntax:
    % @verbitam
    % Fe = calcConstraintForces(obj, cond, model, qe, dqe, u)
    % @endverbatim 
    %
    % Parameters:
    %  cond: the unilateral condition name to be calculated @type char
    %  model: a rigid body model @type RigidBodyModel
    %  qe: the coordinate configuration `q` @type colvec
    %  dqe: the coordinate velocity `\dot{q}` @type colvec
    %  u: the control inputs `u` @type colvec
    %  
    %
    % Return values:
    %  value: the value of the unilateral condition
    
    % check valid condition
    assert(ischar(cond), 'The unilateral condition must be a string');
    
    % extract the information of the specific condition from the table
    uni_cond = obj.UnilateralConstr(cond,:);
    
    switch uni_cond.Type{1}
        case 'Force'            
            % first compute the constraint wrenches
            Fe = calcConstraintForces(obj, model, qe, dqe, u);
            % get the wrench indices associated with the specific
            % unilateral condition
            f_ind = getIndex(obj.HolonomicConstr, uni_cond.KinName{1});
            % compute the unilateral condition
            value = uni_cond.WrenchCondition{1}*Fe(f_ind);
        case 'Kinematic'
            % call the (exported) kinematic function to compute the
            % unilateral condition
            value = feval(uni_cond.KinObject{1}.Funcs.Kin,qe);
    end
end
