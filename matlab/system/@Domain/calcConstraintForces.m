function [Fe] = calcConstraintForces(obj, varargin)
    % Calculates the constraints forces exert on the kinematic constraints
    % of the rigid body model.
    %
    % Use one of the following two syntax:
    % @verbitam
    % Fe = calcConstraintForces(obj, model, qe, dqe, u)
    % @endverbatim
    % or 
    % @verbitam
    % Fe = calcConstraintForces(obj, De, He, Je, Jedot, Be, dqe, u)
    % @endverbatim    
    % The latter option save time if the natural dynamics 
    % has been already computed and input as argumets.
    %
    % Parameters:
    %  varargin: variable input arguments. They could be
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
    
    
    
    switch nargin
        case 5 % the first case
            [model,qe,dqe,u] = deal(varargin{:});
            % compute naturual dynamics
            [De, He] = calcNaturalDynamics(model, qe, dqe);
            
            % Calculate holonomic constraints
            Je    = feval(obj.HolonomicConstr.Funcs.Jac, qe);
            Jedot = feval(obj.HolonomicConstr.Funcs.JacDot, qe, dqe);
            
            
            Be    = obj.ActuationMap;
        case 8
            
            [De, He, Je, Jedot, Be, dqe, u] = deal(varargin{:});
            
            
            
            
    end
    
    XiInv = Je * (De \ transpose(Je));
    % Calculate constrained forces
    Fe = -XiInv \ (Jedot * dqe + Je * (De \ (Be * u - He)));
end
