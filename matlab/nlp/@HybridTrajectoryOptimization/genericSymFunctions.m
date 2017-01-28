function obj = genericSymFunctions(obj)
    % This function creates symbolic functions for the hybrid trajectory
    % optimization problem. 
    %
    % @note This function will only creates mandatory constraints
    % functions. To create user-defined constraints or cost function, it is
    % suggested to write your own function for the purpose.
    %
    % @note This function should be called first by the overloaded method
    % in any inherited classed, if any.
    
    
    model = obj.Model;
    
    
    % natrual dynamics of the rigid body model
    %% De(q)*ddq
    De_ddq = SymFunction('Name', 'inertia_vec', ...
        'Expression', 'De.ddQe');
    De_ddq = setDepSymbols(De_ddq, {'Qe', 'ddQe'});
    De_ddq = setPreCommands(De_ddq, 'Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe, t];');
    De_ddq = setDescription(De_ddq, 'Inertia matrix times joint acceleration: De(q)*ddq)');
    obj.Funcs.Model.De_ddq = De_ddq;
    
    %% Ce(q,dq)
    Ce_dq = SymFunction('Name', 'coriolis_vec', ...
        'Expression', 'Ce.dQe');
    Ce_dq = setDepSymbols(Ce_dq, {'Qe', 'dQe'});
    Ce_dq = setPreCommands(Ce_dq, 'Qe = GetQe[]; dQe = D[Qe, t];');
    Ce_dq = setDescription(Ce_dq, 'Coriolis vector: Ce(q,dq)');
    obj.Funcs.Model.Ce = Ce_dq;
    
    %% Ge(q)
    Ge = SymFunction('Name', 'gravity_vec', ...
        'Expression', 'Ge');
    Ge = setDepSymbols(Ge, {'Qe'});
    Ge = setPreCommands(Ge, 'Qe = GetQe[];');
    Ge = setDescription(Ge, 'Gravity vector: G(q)');
    obj.Funcs.Model.Ge = Ge;
    
    %% Center of Mass 
    
    posCoM = SymFunction('Name', 'posCoM', ...
        'Expression', 'ComputeComPosition[]');
    posCoM = setDepSymbols(posCoM, {'Qe'});
    posCoM = setPreCommands(posCoM, 'Qe = GetQe[];');
    posCoM = setDescription(posCoM, 'Center of mass position: pcom(q)');
    obj.Funcs.Model.pcom = posCoM;
    
    velCoM = SymFunction('Name', 'velCoM', ...
        'Expression', 'D[pcom,t]');
    velCoM = setDepSymbols(velCoM, {'Qe','dQe'});
    velCoM = setPreCommands(velCoM, 'Qe = GetQe[]; dQe = D[Qe, t]; pcom=ComputeComPosition[];');
    velCoM = setDescription(velCoM, 'Center of mass velocity: vcom(q,dq)');
    obj.Funcs.Model.velCoM = velCoM;
    
    accCoM = SymFunction('Name', 'accCoM', ...
        'Expression', 'D[pcom,{t,2}]');
    accCoM = setDepSymbols(accCoM, {'Qe','dQe','ddQe'});
    accCoM = setPreCommands(accCoM, 'Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe, t]; pcom=ComputeComPosition[];');
    accCoM = setDescription(accCoM, 'Center of mass acceleration: acom(q,dq,ddq)');
    obj.Funcs.Model.accCoM = accCoM;
    
    %% delta = 0
    intPosHS = SymFunction('Name', 'intPosHS_vec');
    intPosHS = setPreCommands(intPosHS,...
        ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe,t];',... % states on node i
        'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}]; dQn=D[Qn,t]; ddQn=D[dQn,t];',... % states on next cardinal nodes
        'Qm=Qe/.Subscript[x_,y_]:>Subscript[x,{y,m}]; dQm=D[Qm,t]; ddQm=D[dQm,t];']);  % states on the next middle node
    intPosHS = setExpression(intPosHS,'Qn-Qe-(T/(nNode-1))(dQn+4 dQm+dQe)/6');
    intPosHS = setDepSymbols(intPosHS,{'T','Qe','dQe','dQm','Qn','dQn'});
    intPosHS = setParSymbols(intPosHS,{'nNode'});
    intPosHS = setDescription(intPosHS, 'Position level collocation constraints of Hermite-Simpson scheme.');
    obj.Funcs.Generic.intPosHS = intPosHS;
       
    
    intVelHS = SymFunction('Name', 'intVelHS_vec');
    intVelHS = setPreCommands(intVelHS,...
        ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe,t];',... % states on previous cardinal node i
        'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}]; dQn=D[Qn,t]; ddQn=D[dQn,t];',... % states on next cardinal nodes
        'Qm=Qe/.Subscript[x_,y_]:>Subscript[x,{y,m}]; dQm=D[Qm,t]; ddQm=D[dQm,t];']);  % states on the interior node
    intVelHS = setExpression(intVelHS,'dQn-dQe-(T/(nNode-1))(ddQn+4 ddQm+ddQe)/6');
    intVelHS = setDepSymbols(intVelHS,{'T','dQe','ddQe','ddQm','dQn','ddQn'});
    intVelHS = setParSymbols(intVelHS,{'nNode'});
    intVelHS = setDescription(intVelHS, 'Velocity level collocation constraints of Hermite-Simpson scheme.');
    obj.Funcs.Generic.intVelHS = intVelHS;
    
    %% xi = 0
    midPosHS = SymFunction('Name', 'midPosHS_vec');
    midPosHS = setPreCommands(midPosHS,...
        ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe,t];',... % states on node i
        'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}]; dQn=D[Qn,t]; ddQn=D[dQn,t];',... % states on next cardinal nodes
        'Qm=Qe/.Subscript[x_,y_]:>Subscript[x,{y,m}]; dQm=D[Qm,t]; ddQm=D[dQm,t];']);  % states on the next middle node
    midPosHS = setExpression(midPosHS,'Qm-(Qe+Qn)/2-(T/(nNode-1)) (dQe-dQn)/8');
    midPosHS = setDepSymbols(midPosHS,{'T','Qe','dQe','Qm','Qn','dQn'});
    midPosHS = setParSymbols(midPosHS,{'nNode'});
    midPosHS = setDescription(midPosHS, 'Position level collocation constraints of Hermite-Simpson scheme.');
    obj.Funcs.Generic.midPosHS = midPosHS;
       
    
    midVelHS = SymFunction('Name', 'midVelHS_vec');
    midVelHS = setPreCommands(midVelHS,...
        ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe,t];',... % states on node i
        'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}]; dQn=D[Qn,t]; ddQn=D[dQn,t];',... % states on next cardinal nodes
        'Qm=Qe/.Subscript[x_,y_]:>Subscript[x,{y,m}]; dQm=D[Qm,t]; ddQm=D[dQm,t];']);  % states on the next middle node
    midVelHS = setExpression(midVelHS,'dQm-(dQe+dQn)/2-(T/(nNode-1)) (ddQe-ddQn)/8');
    midVelHS = setDepSymbols(midVelHS,{'T','dQe','ddQe','dQm','dQn','ddQn'});
    midVelHS = setParSymbols(midVelHS,{'nNode'});
    midVelHS = setDescription(midVelHS, 'Velocity level collocation constraints of Hermite-Simpson scheme.');
    obj.Funcs.Generic.midVelHS = midVelHS;
    %% Trapzoidal
    intPosTZ = SymFunction('Name', 'intPosTZ_vec');
    intPosTZ = setPreCommands(intPosTZ,...
        ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe,t];',... % states on node i
        'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}]; dQn=D[Qn,t]; ddQn=D[dQn,t];']);  % states on the next node
    intPosTZ = setExpression(intPosTZ,'Qn-Qe-(T/(nNode-1)) (dQn+dQe)/2');
    intPosTZ = setDepSymbols(intPosTZ,{'T','Qe','dQe','Qn','dQn'});
    intPosTZ = setParSymbols(intPosTZ,{'nNode'});
    intPosTZ = setDescription(intPosTZ, 'Position level collocation constraints of Trapezoidal scheme.');
    obj.Funcs.Generic.intPosTZ = intPosTZ;
       
    
    intVelTZ = SymFunction('Name', 'intVelTZ_vec');
    intVelTZ = setPreCommands(intVelTZ,...
        ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe,t];',... % states on node i
        'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}]; dQn=D[Qn,t]; ddQn=D[dQn,t];']);  % states on the next node
    intVelTZ = setExpression(intVelTZ,'dQn-dQe-(T/(nNode-1)) (ddQn+ddQe)/2');
    intVelTZ = setDepSymbols(intVelTZ,{'T','dQe','ddQe','dQn','ddQn'});
    intVelTZ = setParSymbols(intVelTZ,{'nNode'});
    intVelTZ = setDescription(intVelTZ, 'Velocity level collocation constraints of Trapezoidal scheme.');
    obj.Funcs.Generic.intVelTZ = intVelTZ;
    %% time consistency
    tCont = SymFunction('Name','tCont_sca');
    tCont = setExpression(tCont,'{t-tn}');
    tCont = setDepSymbols(tCont,{'t','tn'});
    tCont = setDescription(tCont,'time consistency');
    obj.Funcs.Generic.tCont = tCont;
    
    
    num_phase = length(obj.Phase);
    
    for i = 1:num_phase
        phase = obj.Phase{i};
        domain = obj.Gamma.Nodes.Domain{phase.CurrentVertex};
        
        %% control dynamics: -B*u-J'(q)*Fe
        control = SymFunction('Name', ['controlDynamics_',domain.Name]);
        control = setPreCommands(control, ...
            ['Qe = GetQe[];',...
            'U = Vec[Table[u[i],{i,',num2str(size(domain.ActuationMap,2)),'}]];',...
            'Fe = Vec[Table[f[i],{i,',num2str(getDimension(domain.HolonomicConstr)),'}]];',...
            'Be = ',mat2math(domain.ActuationMap),';',...
            ]);
        control = setExpression(control, ...
            ['-Be.U - Transpose[',domain.HolonomicConstr.Symbols.Jac,'].Fe']);
        control = setDepSymbols(control, {'Qe','U', 'Fe'});
        control = setDescription(control, 'Right hand side of the Euler Lagrangian equation with negative sign: - Bu - transpose(J(q))Fe');
        phase_funcs.control = control;
        
        
        %% holonomic constraints
        %% h(q) - hbar = 0
        if ~isempty(domain.HolonomicConstr)
            
            holPos = SymFunction('Name', ['holPos_',domain.Name]);
            holPos = setPreCommands(holPos, ...
                ['Qe = GetQe[];',...
                'H = Vec[Table[h[i],{i,',num2str(getDimension(domain.HolonomicConstr)),'}]];',...
                ]);
            holPos = setExpression(holPos, ...
                [domain.HolonomicConstr.Symbols.Kin,'-H']);
            holPos = setDepSymbols(holPos, {'Qe','H'});
            holPos = setDescription(holPos, 'Position level holonomic constraints: h(q) - \bar{h} = 0');
            phase_funcs.holPos = holPos;
            
            %% J(q)*dq = 0
            holVel = SymFunction('Name', ['holVel_',domain.Name]);
            holVel = setPreCommands(holVel, ...
                'Qe = GetQe[]; dQe = D[Qe, t];');
            holVel = setExpression(holVel, ...
                [domain.HolonomicConstr.Symbols.Jac,'.dQe']);
            holVel = setDepSymbols(holVel, {'Qe','dQe'});
            holVel = setDescription(holVel, 'Velocity level holonomic constraints: J(q)*dq = 0');
            phase_funcs.holVel = holVel;
            
            %%  J(q)*ddq + Jdot(q,dq)*dq= 0
            holAcc = SymFunction('Name', ['holAcc_',domain.Name]);
            holAcc = setPreCommands(holAcc, ...
                ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe, t];',...
                'H = Vec[Table[h[i],{i,',num2str(getDimension(domain.HolonomicConstr)),'}]];',...
                ]);
            holAcc = setExpression(holAcc, ...
                [domain.HolonomicConstr.Symbols.Jac,'.ddQe+',...
                domain.HolonomicConstr.Symbols.JacDot,'.dQe']);
            holAcc = setDepSymbols(holAcc, {'Qe','dQe','ddQe'});
            holAcc = setDescription(holAcc, 'Acceleration level holonomic constraints: J(q)*ddq + Jdot(q)*dq = 0');
            phase_funcs.holAcc = holAcc;
        end
        %% guard condition: H(q,dq,Fe) = 0
        if ~phase.IsTerminal
            edge_idx = findedge(obj.Gamma, phase.CurrentVertex, phase.NextVertex);
            guard  = obj.Gamma.Edges.Guard{edge_idx};
            guard_cond = domain.UnilateralConstr(guard.Condition,:);
            guard_func = SymFunction('Name', ['guard_',domain.Name]);
            
            
            
            switch guard_cond.Type{1}
                case 'Kinematic'
                    guard_func = setPreCommands(guard_func, ...
                        ['Qe = GetQe[];']);
                    guard_func = setExpression(guard_func, ...
                        [guard_cond.KinObject{1}.Symbols.Kin,'-threshold']);
                    guard_func = setDepSymbols(guard_func, {'Qe'});
                    guard_func = setParSymbols(guard_func, {'threshold'});
                    guard_func = setDescription(guard_func, 'Kinematic based guard condition H(q) >= 0');
                    phase_funcs.guard_func = guard_func;
                case 'Force'
                    guard_func = setPreCommands(guard_func, ...
                        ['Fe = Vec[Table[f[i],{i,',num2str(getDimension(domain.HolonomicConstr)),'}]];',...
                        ]);
                    f_ind = getIndex(domain.HolonomicConstr, guard_cond.KinName{1});
                    guard_func = setExpression(guard_func, ...
                        ['(First@',mat2math(guard_cond.WrenchCondition{1}),').',...
                        'Fe[[First@',mat2math(f_ind),']]']);
                    guard_func = setDepSymbols(guard_func, {'Fe'});
                    guard_func = setDescription(guard_func, 'Force based guard condition H(Fe) >= 0');
                    phase_funcs.guard_func = guard_func;
            end
            
            qResetMap = SymFunction('Name', ['qResetMap_',domain.Name]);
            if isempty(guard.ResetMap.RelabelMatrix)
                R = eye(model.nDof);
            else
                R = guard.ResetMap.RelabelMatrix;
            end
            if ~isempty(guard.ResetMap.ResetPoint)
                switch model.Type
                    case 'spatial' 
                        n_pos = 3;
                    case 'planar' 
                        n_pos = 2;
                end
                qResetMap = setPreCommands(qResetMap,...
                    ['Qe = GetQe[]; ',... % states on node i
                    'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}];',...
                    'resetPos = Vec[ConstantArray[0,{',num2str(model.nDof),'}]];',...
                    'resetPos[[1;;',num2str(n_pos),']] = Transpose@{Flatten@',guard.ResetMap.ResetPoint.Symbols.Kin,'};']);  % states on the next node
            else
                qResetMap = setPreCommands(qResetMap,...
                    ['Qe = GetQe[]; ',... % states on node i
                    'resetPos = Vec[ConstantArray[0,{',num2str(model.nDof),'}]];',...
                    'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}]; ']);  % states on the next node
            end
            
            
            qResetMap = setExpression(qResetMap,[mat2math(R),'.(Qe-resetPos)-Qn']);
            qResetMap = setDepSymbols(qResetMap,{'Qe','Qn'});
            qResetMap = setDescription(qResetMap, 'Reset map (joint).');
            phase_funcs.qResetMap = qResetMap;
            
            
            dqResetMap = SymFunction('Name', ['dqResetMap_',domain.Name]);
            
            if guard.ResetMap.RigidImpact
                next_domain = obj.Gamma.Nodes.Domain{obj.Phase{i}.NextVertex};
                dqResetMap = setPreCommands(dqResetMap,...
                    ['De = InertiaMatrix[]; Qn = GetQe[]; dQn = D[Qe,t];',... % states on node i
                    'Qe=Qn/.Subscript[x_,y_]:>Subscript[x,{y,n}]; dQe = D[Qe,t];',...
                    'Fi = Vec[Table[fi[i],{i,',num2str(getDimension(next_domain.HolonomicConstr)),'}]];']);
                dqResetMap = setExpression(dqResetMap,...
                    ['De.(dQn-',mat2math(R),'.dQe)-Transpose[',next_domain.HolonomicConstr.Symbols.Jac,'].Fi']);
                dqResetMap = setDepSymbols(dqResetMap,{'dQe','Fi','Qn','dQn'});
            else
                dqResetMap = setPreCommands(dqResetMap,...
                    ['Qe = GetQe[]; dQe = D[Qe,t];',... % states on node i
                    'Qn=Qe/.Subscript[x_,y_]:>Subscript[x,{y,n}]; dQn = D[Qn,t];']);
                dqResetMap = setExpression(dqResetMap,[mat2math(R),'.dQe-dQn']);
                dqResetMap = setDepSymbols(dqResetMap,{'dQe','dQn'});
            end
            
            
            dqResetMap = setDescription(dqResetMap, 'Reset map (joint velocity).');
            phase_funcs.dqResetMap = dqResetMap;
        end
        % outputs
        
        %% Velocity outputs dynamics
        if ~isempty(domain.ActVelocityOutput)            
            %% y1(q,dq,v,p) = 0
            y1Vel = SymFunction('Name', ['y1Vel_', domain.Name]);
            y1Vel = setPreCommands(y1Vel, ...
                ['Qe = GetQe[]; dQe = D[Qe, t];',...
                'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
                'V = Vec[Table[a[i],{i,',num2str(domain.DesVelocityOutput.NumParam),'}]];',...
                ]);
            y1Vel = setExpression(y1Vel,...
                [domain.ActVelocityOutput.Symbols.Jac,'.dQe - (',...
                domain.DesVelocityOutput.Symbols.y,'/.{t->',...
                domain.PhaseVariable.Var.Symbols.Kin,'})']);
            y1Vel = setDepSymbols(y1Vel,{'Qe','dQe','P','V'});
            y1Vel = setDescription(y1Vel,'Velocity output: ya1(q,dq) - yd1(q,p,v) = 0');
            phase_funcs.y1Vel = y1Vel;
            
            %% output dynamics: y1dot(q,dq,ddq,v,p) + epsilon*y1(q,dq,v,p) = 0
            y1Acc = SymFunction('Name', ['y1Acc_', domain.Name]);
            y1Acc = setPreCommands(y1Acc, ...
                ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe,t];',...
                'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
                'V = Vec[Table[a[i],{i,',num2str(domain.DesVelocityOutput.NumParam),'}]];',...
                '$y1vel = ', domain.ActVelocityOutput.Symbols.Jac,'.dQe - (',...
                domain.DesVelocityOutput.Symbols.y,'/.{t->',...
                domain.PhaseVariable.Var.Symbols.Kin,'});',...
                ]);
            y1Acc = setExpression(y1Acc,'D[$y1vel,t] + 10*$y1vel');
            y1Acc = setDepSymbols(y1Acc,{'Qe','dQe','ddQe','P','V'});
            y1Acc = setDescription(y1Acc,'Velocity output: y1dot(q,dq,ddq,p,v) + ep*y1(q,dq,p,v) = 0');
            phase_funcs.y1Acc = y1Acc;
        end
        
        %% Position outputs
        %% y2(q,a,p) = 0
        num_param = domain.DesPositionOutput.NumParam*length(domain.ActPositionOutput.KinGroupTable);
        y2Pos = SymFunction('Name', ['y2Pos_', domain.Name]);
        y2Pos = setPreCommands(y2Pos, ...
            ['Qe = GetQe[];',...
            'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
            'A = Vec[Table[a[i],{i,',num2str(num_param),'}]];',...
            ]);
        y2Pos = setExpression(y2Pos,...
            ['Flatten[',domain.ActPositionOutput.Symbols.Kin,'] - Flatten@(',...
            domain.DesPositionOutput.Symbols.y,'/.{t->',...
            domain.PhaseVariable.Var.Symbols.Kin,'})']);
        y2Pos = setDepSymbols(y2Pos,{'Qe','P','A'});
        y2Pos = setDescription(y2Pos,'Position level: ya2(q) - yd2(q,p,a) = 0');
        phase_funcs.y2Pos = y2Pos;
        
        %% dy2(q,dq,a,p) = 0
        y2Vel = SymFunction('Name', ['y2Vel_', domain.Name]);
        y2Vel = setPreCommands(y2Vel, ...
            ['Qe = GetQe[]; dQe = D[Qe, t];',...
            'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
            'A = Vec[Table[a[i],{i,',num2str(num_param),'}]];',...
            'y2pos = ', 'Flatten[',domain.ActPositionOutput.Symbols.Kin,'] - Flatten@(',...
            domain.DesPositionOutput.Symbols.y,'/.{t->',...
            domain.PhaseVariable.Var.Symbols.Kin,'});',...
            ]);
        y2Vel = setExpression(y2Vel,'D[y2pos,t]');
        y2Vel = setDepSymbols(y2Vel,{'Qe','dQe','P','A'});
        y2Vel = setDescription(y2Vel,'Velocity level: ya2(q,dq) - yd2(q,p,v) = 0');
        phase_funcs.y2Vel = y2Vel;
        %% output dynamics: y2ddot(q,dq,ddq,a,p) + 2*epsilon*y2dot(q,dq,a,p) + epsilon*y2(q,dq,v,p) = 0
        y2Acc = SymFunction('Name', ['y2Acc_', domain.Name]);
        y2Acc = setPreCommands(y2Acc, ...
            ['Qe = GetQe[]; dQe = D[Qe, t]; ddQe = D[dQe,t];',...
            'P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
            'A = Vec[Table[a[i],{i,',num2str(num_param),'}]];',...
            'y2pos = ', 'Flatten[',domain.ActPositionOutput.Symbols.Kin,'] - Flatten@(',...
            domain.DesPositionOutput.Symbols.y,'/.{t->',...
            domain.PhaseVariable.Var.Symbols.Kin,'});',...
            'y2vel = D[y2pos,t];',...
            ]);
        y2Acc = setExpression(y2Acc,'D[y2vel,t]');
        y2Acc = setDepSymbols(y2Acc,{'Qe','dQe','ddQe','P','A'});
        y2Acc = setDescription(y2Acc,'output dynamics: y2ddot(q,dq,ddq,a,p) + 2*epsilon*y2dot(q,dq,a,p) + epsilon*y2(q,dq,v,p) = 0');
        phase_funcs.y2Acc = y2Acc;
        
        %% phase parameters
        
        %% reset map
        % q^- - Rq^+ = 0
        
        
        %% parameter consistency
        %% V - Vn = 0
        if ~isempty(domain.ActVelocityOutput)   
            vCont = SymFunction('Name',['vCont_',domain.Name]);
            vCont = setPreCommands(vCont,...
                ['V = Vec[Table[a[i],{i,',num2str(domain.DesVelocityOutput.NumParam),'}]];',...
                'Vn = Vec[Table[an[i],{i,',num2str(domain.DesVelocityOutput.NumParam),'}]];']);
            vCont = setExpression(vCont,'V-Vn');
            vCont = setDepSymbols(vCont,{'V','Vn'});
            vCont = setDescription(vCont,'Parameter consistency: velocity output - v');
            phase_funcs.vCont = vCont;
        end
        %% P - Pn = 0
        pCont = SymFunction('Name',['pCont_',domain.Name]);
        pCont = setPreCommands(pCont,...
            ['P = Vec[Table[p[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];',...
            'Pn = Vec[Table[pn[i],{i,',num2str(domain.PhaseVariable.Var.Parameters.Dimension),'}]];']);
        pCont = setExpression(pCont,'P - Pn');
        pCont = setDepSymbols(pCont,{'P','Pn'});
        pCont = setDescription(pCont,'Parameter consistency: phase variable - p');
        phase_funcs.pCont = pCont;
        
        
        num_param = domain.DesPositionOutput.NumParam*length(domain.ActPositionOutput.KinGroupTable);
        aCont = SymFunction('Name',['aCont_',domain.Name]);
        aCont = setPreCommands(aCont,...
            ['A = Vec[Table[a[i],{i,',num2str(num_param),'}]];',...
            'An = Vec[Table[an[i],{i,',num2str(num_param),'}]];']);
        aCont = setExpression(aCont,'A-An');
        aCont = setDepSymbols(aCont,{'A','An'});
        aCont = setDescription(aCont,'Parameter consistency: position output - a');
        phase_funcs.aCont = aCont;
        
        hCont = SymFunction('Name',['hCont_',domain.Name]);
        hCont = setPreCommands(hCont,...
            ['H = Vec[Table[h[i],{i,',num2str(getDimension(domain.HolonomicConstr)),'}]];',...
            'Hn = Vec[Table[hn[i],{i,',num2str(getDimension(domain.HolonomicConstr)),'}]];']);
        hCont = setExpression(hCont,'H-Hn');
        hCont = setDepSymbols(hCont,{'H','Hn'});
        hCont = setDescription(hCont,'Parameter consistency: holonomic constraints - hbar');
        phase_funcs.hCont = hCont;
        
        if ~phase.IsTerminal
            
            cur_num_param = domain.DesPositionOutput.NumParam*length(domain.ActPositionOutput.KinGroupTable);
            
            next_domain = obj.Gamma.Nodes.Domain{obj.Phase{i}.NextVertex};
            next_num_param = next_domain.DesPositionOutput.NumParam*length(next_domain.ActPositionOutput.KinGroupTable);
            aPhaseCont = SymFunction('Name',['aPhaseCont_',domain.Name]);
            aPhaseCont = setPreCommands(aPhaseCont,...
                ['A = Vec[Table[a[i],{i,',num2str(cur_num_param),'}]];',...
                'An = Vec[Table[an[i],{i,',num2str(next_num_param),'}]];']);
            
            cur_same_output_indices = getPositionOutputIndex(domain,{next_domain.ActPositionOutput.KinGroupTable.Name});
            next_same_output_indices = getPositionOutputIndex(next_domain,{domain.ActPositionOutput.KinGroupTable.Name});
            
            cur_param_indices = (cur_same_output_indices - 1)*domain.DesPositionOutput.NumParam + ...
                cumsum(ones(domain.DesPositionOutput.NumParam,1));
            next_param_indices = (next_same_output_indices - 1)*next_domain.DesPositionOutput.NumParam + ...
                cumsum(ones(next_domain.DesPositionOutput.NumParam,1));
            aPhaseCont = setExpression(aPhaseCont,['A[[Flatten[',mat2math(cur_param_indices(:)),']]]-',...
                'An[[Flatten[',mat2math(next_param_indices(:)),']]]']);
            aPhaseCont = setDepSymbols(aPhaseCont,{'A','An'});
            aPhaseCont = setDescription(aPhaseCont,'Parameter consistency between two domains: position output - a');
            phase_funcs.aPhaseCont = aPhaseCont;
            
            
%             hPhaseCont = SymFunction('Name',['hPhaseCont_',domain.Name]);
%             hPhaseCont = setPreCommands(hPhaseCont,...
%                 ['H = Vec[Table[h[i],{i,',num2str(getDimension(domain.HolonomicConstr)),'}]];',...
%                 'Hn = Vec[Table[hn[i],{i,',num2str(getDimension(next_domain.HolonomicConstr)),'}]];']);
%             cur_same_constr_indices = getHolonomicConstrIndex(domain,{next_domain.HolonomicConstr.KinGroupTable.Name});
%             next_same_constr_indices = getHolonomicConstrIndex(next_domain,{domain.HolonomicConstr.KinGroupTable.Name});
%             
%             hPhaseCont = setExpression(hPhaseCont,['H[[Flatten[',mat2math(cur_same_constr_indices(:)),']]]-',...
%                 'Hn[[Flatten[',mat2math(next_same_constr_indices(:)),']]]']);
%             
%             hPhaseCont = setDepSymbols(hPhaseCont,{'H','Hn'});
%             hPhaseCont = setDescription(hPhaseCont,'Parameter consistency between two domains: holonomic constraints - hbar');
%             phase_funcs.hPhaseCont = hPhaseCont;
        end
        
        
        %% ZMP (unilateral constraints on forces)
        force_cond_table = domain.UnilateralConstr(strcmp(domain.UnilateralConstr.Type,'Force'),:);
        
        if ~isempty(force_cond_table)
            zmp = SymFunction('Name', ['zmp_',domain.Name]);
            n_hol_constr = getDimension(domain.HolonomicConstr);
            zmp = setPreCommands(zmp, ...
                ['Fe = Vec[Table[f[i],{i,',num2str(n_hol_constr),'}]];',...
                ]);
            wrench_condition = zeros(0,n_hol_constr);
            for k=1:height(force_cond_table)
                f_ind = getIndex(domain.HolonomicConstr, force_cond_table.KinName{k});
                w_cond = force_cond_table.WrenchCondition{k};
                w_cond_new = zeros(size(w_cond,1),n_hol_constr);
                w_cond_new(:,f_ind) = w_cond;
                wrench_condition = [wrench_condition;w_cond_new]; %#ok<AGROW>
            end
            zmp = setExpression(zmp, ...
                [mat2math(wrench_condition),'.Fe']);
            zmp = setDepSymbols(zmp, {'Fe'});
            zmp = setDescription(zmp, 'Zero moment point constraints');
            phase_funcs.zmp = zmp;
        end
        
        
        %% Other kinematic unilateral constraints
        kin_cond_table = domain.UnilateralConstr(strcmp(domain.UnilateralConstr.Type,'Kinematic'),:);
        
        if ~isempty(kin_cond_table)
            kinUnilateral = SymFunction('Name', ['unilateral_',domain.Name]);
           
            kinUnilateral = setPreCommands(kinUnilateral, ...
                'Qe = GetQe[];');
           
            kin_symbols = cellfun(@(x) x.Symbols,kin_cond_table.KinObject);
            kinUnilateral = setExpression(kinUnilateral, ...
                ['Join[Sequence@@',cell2tensor({kin_symbols.Kin},'ConvertString',false),']']);
            kinUnilateral = setDepSymbols(kinUnilateral, {'Qe'});
            kinUnilateral = setDescription(kinUnilateral, 'Kinematic based unilateral conditions v(q) >= 0');
            phase_funcs.kinUnilateral = kinUnilateral;
        end
        
      
        
        %% cost function
        power = SymFunction('Name', ['power_',domain.Name]);
        power = setPreCommands(power, ...
            ['Qe = GetQe[]; dQe = D[Qe,t]; ',...
            'U = Vec[Table[u[i],{i,',num2str(size(domain.ActuationMap,2)),'}]];',...
            'Be = ',mat2math(domain.ActuationMap),';']);
        power = setExpression(power, ...
            'First@Sqrt[Transpose[U*Transpose[Be].dQe].(U*Transpose[Be].dQe)]');
        power = setDepSymbols(power, {'dQe','U'});
        power = setDescription(power, 'power consumed at all actuated joints.');
        phase_funcs.power = power;
        
        obj.Funcs.Phase{i} = phase_funcs;
    end
    
end