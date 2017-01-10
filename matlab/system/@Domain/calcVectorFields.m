function [vfc, gfc] = calcVectorFields(obj, model, qe, dqe, De, He)
    % Calculates the vector fields of the affine control system 
    % `dot{x} = f(x) + g(x)*u` for the constrained dynamics
    %
    %
    %
    % Use one of the following two syntax:
    % @verbitam
    % [vfc, gfc] = calcVectorFields(obj, model, qe, dqe)
    % @endverbatim
    % or 
    % @verbitam
    % [vfc, gfc] = calcVectorFields(obj, model, qe, dqe, De, He)
    % @endverbatim    
    % The latter option save time if the natural dynamics 
    % has been already computed and input as argumets.
    %
    %
    % Parameters:
    %  model: a rigid body model of type RigidBodyModel
    %  qe: the coordinate configuration `q` @type colvec
    %  dqe: the coordinate velocity `\dot{q}` @type colvec
    %  De: (optional) the inertia matrix of the rigid body 
    %  model `D(q)` @type matrix
    %  He: (optional) the corilios, gravity and internal force vector 
    %  `H(q,\dot{q})` @type colvec
    %
    % Return values:
    %  vfc: the vector field `f(x)` @type colvec
    %  gfc: the vector field `g(x)` @type colvec
    
    % compute naturual dynamics
    if nargin < 5
        [De, He] = calcNaturalDynamics(model, qe, dqe);
    end
    
    % Calculate holonomic constraints
    Je    = feval(obj.HolFuncs.Jac, qe);
    Jedot = feval(obj.HolFuncs.JacDot, qe, dqe);
    
    Ie    = eye(model.nDof);
    Be    = obj.ActuationMap;
    
    XiInv = Je * (De \ transpose(Je));
    
    % compute vector fields
    % f(x)
    vfc = [
        dqe;
        De \ ((transpose(Je) * (XiInv \ (transpose(transpose(De) \ transpose(Je)))) -...
        Ie) * He - transpose(Je) * (XiInv \ Jedot * dqe))];
    
    
    % g(x)
    gfc = [
        zeros(size(Be));
        De \ (Ie - transpose(Je)* (XiInv \ (transpose(transpose(De) \ transpose(Je))))) * Be];
    
   
end
