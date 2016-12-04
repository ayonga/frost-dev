function [Fe] = calcConstraintForces(obj, model, qe, dqe, u, De, He)
    % Calculates the constraints forces exert on the kinematic constraints
    % of the rigid body model.
    %
    % Use one of the following two syntax:
    % @verbitam
    % Fe = calcConstraintForces(obj, model, qe, dqe)
    % @endverbatim
    % or 
    % @verbitam
    % Fe = calcConstraintForces(obj, model, qe, dqe, De, He)
    % @endverbatim    
    % The latter option save time if the natural dynamics 
    % has been already computed and input as argumets.
    %
    % Parameters:
    %  model: a rigid body model of type RigidBodyModel
    %  qe: the coordinate configuration `q` @type colvec
    %  dqe: the coordinate velocity `\dot{q}` @type colvec
    %  u: the control inputs `u` @type colvec
    %  De: (optional) the inertia matrix of the rigid body 
    %  model `D(q)` @type matrix
    %  He: (optional) the corilios, gravity and internal force vector 
    %  `H(q,\dot{q})` @type colvec
    %  
    %
    % Return values:
    %  Fe: the external constraint forces `Fe(q,\dot{q},u)` @type colvec
    
    % compute naturual dynamics
    
    if nargin < 6
        [De, He] = calcNaturalDynamics(model, qe, dqe);
    end
    
    % Calculate holonomic constraints
    Je    = feval(obj.funcs.hol_constr, qe);
    Jedot = feval(obj.funcs.jac_hol_constr, {qe,dqe});
    
    
    Be    = obj.actuator_map;
    
    XiInv = Je * (De \ transpose(Je));
    
    
    % Calculate constrained forces
    Fe = -XiInv \ (Jedot * dqe + Je * (De \ (Be * u - He)));
end
