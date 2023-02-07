function nlp = imposeNLPConstraint(obj, nlp, varargin)
    % Add system dynamics equations as a set of equality constraints   
    %

    
    nDof = obj.Dimension;
    V0 = zeros(6,1);
    dV0 = [0;0;9.81;0;0;0];
    
    
    x = obj.States.x;
    dx = obj.States.dx;
    ddx = obj.States.ddx;
    
    
    base_joints_name = {obj.BaseJoints.Name};
    
    
    for j_idx=1:nDof
        joint = obj.Joints(j_idx);
        v_name = ['v',num2str(j_idx)];
        dv_name = ['dv',num2str(j_idx)];
        V = obj.States.(v_name);
        dV = obj.States.(dv_name);
        
        if ~isempty(str_index(joint.Name,base_joints_name))
            prev_j_idx = 0;
        else
            prev_j_idx = getJointIndices(obj, joint.Reference.Name);
        end
        
        B_i = joint.TwistAxis;
        M_i = joint.Tinv;
        T_i = twist_exp(-B_i,x(j_idx)) * M_i;
        
               
        if prev_j_idx==0
            V_p = V0;
            dV_p = dV0;
            
            expr_V = V - CoordinateFrame.RigidAdjoint(T_i) * V_p - B_i*dx(j_idx);  %deps: V, x, dx
            expr_V_fun = SymFunction(['BodyTwist',num2str(j_idx),'_',obj.Name],expr_V,{x,dx,V});
            nlp = addNodeConstraint(nlp, 'all', expr_V_fun, {'x','dx', v_name}, 0, 0);
            
            expr_dV = dV - CoordinateFrame.RigidAdjoint(T_i) * dV_p - ...
                CoordinateFrame.LieBracket(V) * (B_i*dx(j_idx)) - B_i*ddx(j_idx); %deps: V, dV, x, dx, ddx
            expr_dV_fun = SymFunction(['BodyTwistDot',num2str(j_idx),'_',obj.Name],expr_dV,{x,dx,ddx,V,dV});
            nlp = addNodeConstraint(nlp, 'all', expr_dV_fun, {'x','dx', 'ddx',v_name,dv_name}, 0,0);
            
        else
            vp_name = ['v',num2str(prev_j_idx)];
            dvp_name = ['dv',num2str(prev_j_idx)];
            V_p = obj.States.(vp_name);
            dV_p = obj.States.(dvp_name);
            
            
            expr_V = V - CoordinateFrame.RigidAdjoint(T_i) * V_p - B_i*dx(j_idx);  %deps: V, V_p, x, dx
            expr_V_fun = SymFunction(['JointTwist',num2str(j_idx),'_',obj.Name],expr_V,{x,dx,V,V_p});
            nlp = addNodeConstraint(nlp, 'all', expr_V_fun, {'x','dx', v_name, vp_name}, 0, 0);
            
            expr_dV = dV - CoordinateFrame.RigidAdjoint(T_i) * dV_p - ...
                CoordinateFrame.LieBracket(V) * (B_i*dx(j_idx)) - B_i*ddx(j_idx); %deps: V, dV, dV_p, x, dx, ddx
            expr_dV_fun = SymFunction(['JointTwistDot',num2str(j_idx),'_',obj.Name],expr_dV,{x,dx,ddx,V,dV,dV_p});
            
            nlp = addNodeConstraint(nlp, 'all', expr_dV_fun, {'x','dx', 'ddx', v_name, dv_name, dvp_name}, 0, 0);
        end
        
    end
        
    for j_idx=1:nDof
        joint = obj.Joints(j_idx);
        f_name = ['f',num2str(j_idx)];
        v_name = ['v',num2str(j_idx)];
        dv_name = ['dv',num2str(j_idx)];
        f = obj.States.(f_name);
        V = obj.States.(v_name);
        dV = obj.States.(dv_name);
        
        G_i = joint.G;
       
        expr_F = f - G_i * dV + transpose(CoordinateFrame.LieBracket(V)) * (G_i * V); 
        deps = {V,dV,f};
        deps_label = {v_name, dv_name, f_name};
        
        if ~isempty(joint.ChildJoints)
            
            for idx =1:numel(joint.ChildJoints)
                child_joint = joint.ChildJoints(idx);
                
                next_j_idx = getJointIndices(obj, child_joint.Name);
                fn_name = ['f',num2str(next_j_idx)];
                f_next = obj.States.(fn_name);
                
                B_next = child_joint.TwistAxis;
                M_next = child_joint.Tinv;
                T_next = twist_exp(-B_next,x(next_j_idx)) * M_next;
                
                
        
                expr_F = expr_F - transpose(CoordinateFrame.RigidAdjoint(T_next)) * f_next;
                deps = [deps, {f_next}]; 
                deps_label = [deps_label, {fn_name}]; 
            end
            
            
            deps = [deps, {x}];
            deps_label = [deps_label, {'x'}];
        end
        
                
        expr_f_fun = SymFunction(['JointWrench',num2str(j_idx),'_',obj.Name],expr_F,deps);
        nlp = addNodeConstraint(nlp, 'all', expr_f_fun, deps_label, 0, 0);
    end
    
    
    
%     tau = SymExpression(zeros(nDof,1));
    tau = cell(nDof,1);
    deps = {x,dx,ddx};
    deps_label = {'x','dx','ddx'};
    for j_idx=1:nDof
        joint = obj.Joints(j_idx);
        
        f_name = ['f',num2str(j_idx)];
        f = obj.States.(f_name);
        if ~isempty(joint.Actuator)
            act = joint.Actuator;
                
            B_i = joint.TwistAxis;
            Vm = B_i*act.GearRatio*dx(j_idx);
            dVm= adV(Vm) * (Vm) + B_i*act.GearRatio*ddx(j_idx);
            fexpr = f + ...
                B_i.*((act.GearRatio)*(joint.Gm * dVm - transpose(adV(Vm)) * (joint.Gm * Vm)));
               
        else
            fexpr = f;
        end
        
        
        tau{j_idx} = transpose(joint.TwistAxis)*fexpr;
        deps = [deps, {f}]; %#ok<*AGROW>
        deps_label = [deps_label,{f_name}];
    end
    
    
    
    expr = transpose([tau{:}]);
    
    % inputs
    input_names = fieldnames(obj.Inputs);
    n_inputs = numel(input_names);
    if n_inputs > 0
        for j=1:n_inputs
            input = input_names{j};
            f = obj.Inputs.(input);
            deps = [deps, {f}];
            deps_label = [deps_label, {input}];
            
            Gmap = f.Gmap;
            expr = expr -  Gmap*f;
        end
    end
    
   
    
    
    expr_Torque_fun = SymFunction(['dynamics_equation_',obj.Name],expr,deps);
    
    nlp = addNodeConstraint(nlp, 'all', expr_Torque_fun, deps_label, 0, 0);
        
        
    
    
end
