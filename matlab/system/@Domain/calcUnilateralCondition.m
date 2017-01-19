function value = calcUnilateralCondition(obj, cond, model, qe, dqe, u)
    % Calculates the unilateral condition specified by ''cond''
    %
    % Use the syntax:
    % @verbitam
    % Fe = calcConstraintForces(obj, cond, model, qe, dqe, u)
    % @endverbatim 
    %
    % Parameters:
    %  cond: the list of unilaternal constraints @type cell
    %  model: a rigid body model @type RigidBodyModel
    %  qe: the coordinate configuration `q` @type colvec
    %  dqe: the coordinate velocity `\dot{q}` @type colvec
    %  u: the control inputs `u` @type colvec
    %  
    %
    % Return values:
    %  value: the value of the unilateral condition
    
    
    % extract the information of the specific condition from the table
    uni_con = obj.UnilateralConstr(cond,:);
    
    n_cond = height(uni_con);
    value = nan(1,n_cond);
    
    if any(strcmp('Force', uni_con.Type))
        % if any of the unilaternal condition regards force, first compute
        % the constraints wrench
        Fe = calcConstraintForces(obj, model, qe, dqe, u);
    end
    
    for i=1:n_cond
        temp_con = uni_con(i,:);
        switch temp_con.Type{1}
            case 'Force'                
                % get the wrench indices associated with the specific
                % unilateral condition
                f_ind = getIndex(obj.HolonomicConstr, temp_con.KinName{1});
                % compute the unilateral condition
                value(i) = temp_con.WrenchCondition{1}*Fe(f_ind);
            case 'Kinematic'
                % call the (exported) kinematic function to compute the
                % unilateral condition
                value(i) = feval(temp_con.KinObject{1}.Funcs.Kin,qe);
        end
    
    end
end
