function tau = inverseDynamics(obj, q, dq, ddq, lambda, g)
    % calculates the Euler-Newton inverse dynamics
    %
    % Parameters:
    % x: joint position vector @type colvec
    % dx: joint velocity vector @type colvec
    % ddx: joint acceleration vector @type colvec
    % lambda: lagrangian multiplier @type struct
    % g: the gravity vector @type colvec
    %
    % Return values:
    % tau: the joint torques @type colvec
    
    
    if nargin < 5
        lambda = struct;
    end
    
    if nargin < 6
        g = obj.g;
    end
    
    nDof = obj.Dimension;
    V0 = zeros(6,1);
    dV0 = [g;0;0;0];
        
    for i=1:nDof
        obj.Joints(i).q = q(i);
        obj.Joints(i).dq = dq(i);
        obj.Joints(i).ddq = ddq(i);
    end
    
    for i=1:length(obj.BaseJoints)
        computeJointTwist(obj, obj.BaseJoints(i), V0, dV0);
        
        computeJointWrench(obj, obj.BaseJoints(i));
        
    end
    
    tau = zeros(nDof,1);
    for i=1:nDof
        joint = obj.Joints(i);
        tau(i) = transpose(joint.TwistAxis)*joint.F;
    end
    %     Fvec = vertcat(obj.Joints.F);
    %
    %     tau = obj.Amat*Fvec;
    
    if ~isempty(lambda)
        Gv = zeros(obj.Dimension,1);
        l_fields = fieldnames(lambda);
        for l_idx = 1:numel(l_fields)
            input = obj.Inputs.(l_fields{l_idx});
            Gmap = feval(input.Gmap.Name,q);
            Gv = Gv + Gmap*lambda.(l_fields{l_idx});
        end
        
        tau = tau - Gv;
    end
    

    
    function computeJointTwist(obj, joint, v_p, dv_p)
        
                
        
        B_i = joint.TwistAxis;
        M_i = joint.Tinv;
        T_i = twist_exp(-B_i,joint.q) * M_i;
        joint.V = rigid_adjoint(T_i) * v_p + B_i*joint.dq;
        joint.dV = rigid_adjoint(T_i) * dv_p + ...
            adV(joint.V) * (B_i*joint.dq) + B_i*joint.ddq;
        
        if ~isempty(joint.Actuator)
            actuator = joint.Actuator;
            if ~isempty(joint.Actuator)
                joint.Vm = B_i*actuator.GearRatio*joint.dq; 
                joint.dVm= adV(joint.Vm) * (joint.Vm) + B_i*actuator.GearRatio*joint.ddq;
            end
        end
        
        if ~isempty(joint.ChildJoints)
            for idx =1:numel(joint.ChildJoints)
                computeJointTwist(obj, joint.ChildJoints(idx), joint.V, joint.dV)
            end
        end
    end

    function computeJointWrench(obj, joint)
        
        if ~isempty(joint.ChildJoints)
            for idx =1:numel(joint.ChildJoints)
                computeJointWrench(obj, joint.ChildJoints(idx));
            end
        end
        
        joint.F = joint.G * joint.dV - transpose(adV(joint.V)) * (joint.G * joint.V);
            
        if ~isempty(joint.ChildJoints)
            for idx =1:numel(joint.ChildJoints)                
                child_joint = joint.ChildJoints(idx);
                B_c = child_joint.TwistAxis;
                M_c = child_joint.Tinv;
                T_c = twist_exp(-B_c,child_joint.q) * M_c;
                joint.F = joint.F + transpose(rigid_adjoint(T_c)) * child_joint.F;      
                
                if ~isempty(child_joint.Actuator)
                    act = child_joint.Actuator;
                    if ~isempty(act)
                        child_joint.F = child_joint.F + ...
                            B_c.*((act.GearRatio)*(child_joint.Gm * child_joint.dVm - transpose(adV(child_joint.Vm)) * (child_joint.Gm * child_joint.Vm)));
                        
                    end
                end
            end            
        end        
    end


end

