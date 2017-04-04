function obj = addOutputRD2Constraint(obj,params,ddx)
    % Add direct collocation equations as a set of equality constraints
    %
    %
    % Parameters:
    % params: the parameters for the feedback term (Kd,Kp) @type struct
    % ddx: the second order derivatives of the states @type SymVariable
    
    
    
    % basic information of NLP decision variables
    nNode  = obj.NumNode;
    vars   = obj.OptVarTable;
    plant  = obj.Plant;
    ceq_err_bound = obj.Options.EqualityConstraintBoundary;
    
    Kd = params.Kd;
    Kp = params.Kp;
    
    
    assert(~isempty(plant.RD2Output),'The relative degree two outputs are not defined.');
    if isa(plant,'FirstOrderSystem')
        fx = outputRD2Constraints(plant,obj.Options,ddx);
    else
        fx = outputRD2Constraints(plant,obj.Options);
    end
    
    
    y_cstr= struct();
    y_cstr.Name = fx.y2.Name;
    y_cstr.lb = -ceq_err_bound;
    y_cstr.ub = ceq_err_bound;
    y_cstr.Type = 'Nonlinear';
    y_cstr.SymFun = fx.y2;
    
    dy_cstr= struct();
    dy_cstr.Name = fx.dy2.Name;
    dy_cstr.lb = -ceq_err_bound;
    dy_cstr.ub = ceq_err_bound;
    dy_cstr.Type = 'Nonlinear';
    dy_cstr.SymFun = fx.dy2;
    
    ddy_cstr(nNode) = struct();
    [ddy_cstr.Name] = deal(fx.ddy2.Name);
    [ddy_cstr.lb] = deal(-ceq_err_bound);
    [ddy_cstr.ub] = deal(ceq_err_bound);
    [ddy_cstr.Type] = deal('Nonlinear');
    [ddy_cstr.SymFun] = deal(fx.ddy2);
    
    if strcmp(plant.RD2Output.Type,'StateBased')
        y_cstr.DepVariables = [vars.x(1);vars.a(1)];
        
        
        
        dy_cstr.DepVariables = [vars.x(1);vars.dx(1);vars.a(1)];
        
        [ddy_cstr.AuxData] = deal([Kd,Kp]);
        for i=1:nNode
            if obj.Options.DistributeParameters
                node_params = i;
            else
                node_params = 1;
            end
            ddy_cstr(i).DepVariables = [vars.x(i);vars.dx(i);vars.a(node_params)];
            
        end
    elseif strcmp(obj.RD2Output.Type,'TimeBased')
        
        if ~isnan(obj.Options.ConstantTimeHorizon)
            T = obj.Options.ConstantTimeHorizon;
            y_cstr.AuxData = [T,1,nNode];
            y_cstr.DepVariables = [vars.x(1);vars.a(1)];
            
            dy_cstr.AuxData = [T,1,nNode];
            dy_cstr.DepVariables = [vars.x(1);vars.dx(1);vars.a(1)];
            
            
            for i=1:nNode
                if obj.Options.DistributeParameters
                    node_params = i;
                else
                    node_params = 1;
                end
                ddy_cstr(i).AuxData = deal([Kd,Kp,T,i,nNode]);
                ddy_cstr(i).DepVariables = [vars.x(i);vars.dx(i);vars.a(node_params)];
                
            end
        else
            y_cstr.AuxData = [1,nNode];
            y_cstr.DepVariables = [vars.T(1);vars.x(1);vars.a(1)];
            
            dy_cstr.AuxData = [1,nNode];
            dy_cstr.DepVariables = [vars.T(1);vars.x(1);vars.dx(1);vars.a(1)];
            
            for i=1:nNode
                if obj.Options.DistributeParameters
                    node_params = i;
                else
                    node_params = 1;
                end
                if obj.Options.DistributeTimeVariable
                    node_time = i;
                else
                    node_time = 1;
                end
                ddy_cstr(i).AuxData = deal([Kd,Kp,i,nNode]);
                ddy_cstr(i).DepVariables = [vars.T(node_time);
                    vars.x(i);vars.dx(i);vars.a(node_params)];
                
            end
        end
        
    end
    
    obj = addConstraint(obj,'y2','first',y_cstr);
    
    obj = addConstraint(obj,'dy2','first',dy_cstr);
    
    obj = addConstraint(obj,'ddy2','all',ddy_cstr);
end