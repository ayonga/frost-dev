function tau = calcDriftVector(obj, q, dq)

    nDof = obj.Dimension;
    V0 = zeros(6,1);
    dV0 = [obj.g;0;0;0];
    V = zeros(6,nDof);
    dV = zeros(6,nDof);
    T_i = cell(nDof,1);
    Adj_i = cell(nDof,1);
    adV_i = cell(nDof,1);
    % compute body twists
    for i=1:nDof
        
        idx = obj.JointIndices(i);        
        if i==1
            v_p = V0;
            dv_p = dV0;
        else
            v_p = V(:,obj.Joints(idx).ChainIndices(end-1));
            dv_p = dV(:,obj.Joints(idx).ChainIndices(end-1));
        end
        
        B_i = obj.Joints(idx).TwistAxis;
        M_i = obj.Joints(idx).Tinv;
        T_i{idx} = twist_exp(-B_i,q(idx)) * M_i;
        Adj_i{idx} = rigid_adjoint(T_i{idx});
        V(:,idx) = Adj_i{idx} * v_p + B_i*dq(idx);
        adV_i{idx} = adV(V(:,idx));
        dV(:,idx) = Adj_i{idx} * dv_p + adV_i{idx} * (B_i*dq(idx));
        
    end
    F = zeros(6,nDof);
    for i=nDof:-1:1
        idx = obj.JointIndices(i); 
        F(:,idx) = obj.Joints(idx).G * dV(:,idx) - transpose(adV_i{idx}) * (obj.Joints(idx).G * V(:,idx));
        
        for c_idx = obj.Joints(idx).ChildJointIndices
            F(:,idx) = F(:,idx) + transpose(Adj_i{c_idx}) * F(:,c_idx);
        end
        
    end

    
    tau = zeros(nDof,1);
    for idx=1:nDof
        tau(idx) = transpose(obj.Joints(idx).TwistAxis)*F(:,idx);
    end

end