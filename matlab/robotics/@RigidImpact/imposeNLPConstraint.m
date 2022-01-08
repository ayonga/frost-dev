function nlp = imposeNLPConstraint(obj, nlp, varargin)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object of the system
    % @type TrajectoryOptimization
    % varargin: extra argument @type varargin
    
    
    
    nDof = obj.Dimension;
    V0 = zeros(6,1);
    
    
    x = obj.States.x;
    dx = obj.States.dx;
    
    xn = obj.States.xn;
    dxn = obj.States.dxn;
    
    x_map = SymFunction(['xDiscreteMap_' obj.Name],obj.R*x-xn,{x,xn});
    
    addNodeConstraint(nlp, 'first', x_map, {x.Name,xn.Name}, 0, 0);
    
    
    model = obj.PostImpactModel;
    base_joints = model.BaseJoints;
    base_joints_name = {base_joints.Name};
    
    for j_idx=1:nDof
        joint = model.Joints(j_idx);
        v_name = ['v',num2str(j_idx)];
        vn_name = ['vn',num2str(j_idx)];
        V = obj.States.(v_name);
        Vn = obj.States.(vn_name);
        
        if ~isempty(str_index(joint.Name,base_joints_name))
            prev_j_idx = 0;
        else
            prev_j_idx = getJointIndices(model, joint.Reference.Name);
        end
        
        B_i = joint.TwistAxis;
        M_i = joint.Tinv;
        T_i = twist_exp(-B_i,xn(j_idx)) * M_i;
        
               
        if prev_j_idx==0
            V_p = V0;
            Vn_p = V0;
            
            expr_V = V - CoordinateFrame.RigidAdjoint(T_i) * V_p - B_i*obj.R(j_idx,:)*dx;  %deps: V, x, dx
            expr_V_fun = SymFunction(['BodyTwistPre',num2str(j_idx),'_',obj.Name],expr_V,{xn,dx,V});
            nlp = addNodeConstraint(nlp, 'first', expr_V_fun, {'xn','dx', v_name}, 0, 0);
            
            expr_Vn = Vn - CoordinateFrame.RigidAdjoint(T_i) * Vn_p - B_i*dxn(j_idx);  %deps: V, x, dx
            expr_Vn_fun = SymFunction(['BodyTwistPost',num2str(j_idx),'_',obj.Name],expr_Vn,{xn,dxn,Vn});
            nlp = addNodeConstraint(nlp, 'first', expr_Vn_fun, {'xn','dxn', vn_name}, 0, 0);
            
        else
            vp_name = ['v',num2str(prev_j_idx)];
            vnp_name = ['vn',num2str(prev_j_idx)];
            V_p = obj.States.(vp_name);
            Vn_p = obj.States.(vnp_name);
            
            
            expr_V = V - CoordinateFrame.RigidAdjoint(T_i) * V_p - B_i*obj.R(j_idx,:)*dx;  %deps: V, V_p, x, dx
            expr_V_fun = SymFunction(['JointTwistPre',num2str(j_idx),'_',obj.Name],expr_V,{xn,dx,V,V_p});
            nlp = addNodeConstraint(nlp, 'first', expr_V_fun, {'xn','dx', v_name, vp_name}, 0, 0);
            
            expr_Vn = Vn - CoordinateFrame.RigidAdjoint(T_i) * Vn_p - B_i*dxn(j_idx);  %deps: V, V_p, x, dx
            expr_Vn_fun = SymFunction(['JointTwistPost',num2str(j_idx),'_',obj.Name],expr_Vn,{xn,dxn,Vn,Vn_p});
            nlp = addNodeConstraint(nlp, 'first', expr_Vn_fun, {'xn','dxn', vn_name, vnp_name}, 0, 0);
        end
        
    end
        
    for j_idx=1:nDof
        joint = model.Joints(j_idx);
        f_name = ['f',num2str(j_idx)];
        v_name = ['v',num2str(j_idx)];
        vn_name = ['vn',num2str(j_idx)];
        f = obj.States.(f_name);
        V = obj.States.(v_name);
        Vn = obj.States.(vn_name);
        
        G_i = joint.G;
       
        expr_F = f - G_i * (Vn - V); 
        deps = {V,Vn,f};
        deps_label = {v_name, vn_name, f_name};
        
        if ~isempty(joint.ChildJoints)
            
            for idx =1:numel(joint.ChildJoints)
                child_joint = joint.ChildJoints(idx);
                
                next_j_idx = getJointIndices(model, child_joint.Name);
                fn_name = ['f',num2str(next_j_idx)];
                f_next = obj.States.(fn_name);
                
                B_next = child_joint.TwistAxis;
                M_next = child_joint.Tinv;
                T_next = twist_exp(-B_next,xn(next_j_idx)) * M_next;
                
                
        
                expr_F = expr_F - transpose(CoordinateFrame.RigidAdjoint(T_next)) * f_next;
                deps = [deps, {f_next}]; 
                deps_label = [deps_label, {fn_name}]; 
            end
            
            
            deps = [deps, {xn}];
            deps_label = [deps_label, {'xn'}];
        end
        
                
        expr_f_fun = SymFunction(['JointWrench',num2str(j_idx),'_',obj.Name],expr_F,deps);
        nlp = addNodeConstraint(nlp, 'first', expr_f_fun, deps_label, 0, 0);
    end
    
    
    
    %     tau = SymExpression(zeros(nDof,1));
    tau = cell(nDof,1);
    deps = {xn, dx, dxn};
    deps_label = {'xn', 'dx', 'dxn'};
    for j_idx=1:nDof
        joint = model.Joints(j_idx);
        
        f_name = ['f',num2str(j_idx)];
        f = obj.States.(f_name);
        if ~isempty(joint.Actuator)
            act = joint.Actuator;
            if ~isempty(act)
                
                B_i = joint.TwistAxis;
                fexpr = f + ...
                    B_i.*(act.GearRatio*(joint.Gm * B_i*act.GearRatio*(dxn(j_idx) -  obj.R(j_idx,:)*dx)));
                
            end
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
            if strcmp(f.Category,'ConstraintWrench')
                deps = [deps, {f}];
                deps_label = [deps_label, {input}];
                
                Gmap = subs(f.Gmap,x,xn);
                expr = expr -  Gmap*f;
            end
        end
    end
    
   
    
    
    expr_Torque_fun = SymFunction(['dynamics_equation_',obj.Name],expr,deps);
    
    nlp = addNodeConstraint(nlp, 'first', expr_Torque_fun, deps_label, 0, 0);
    
end
