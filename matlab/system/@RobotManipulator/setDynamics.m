function obj = setDynamics(obj)
    % Set the symbolic expressions of the dynamics of the rigid body system
    %
    
    
    % set the inertia matrix 
    De = eval_math_fun('InertiaMatrix',{obj.SymLinks,obj.SymTwists});
    obj.setMassMatrix(De);
    
    Qe = obj.States.x;
    dQe = obj.States.dx;
    
    Ce1 = cell(obj.numState,1);
    Ce2 = cell(obj.numState,1);
    Ce3 = cell(obj.numState,1);
    for i=1:obj.numState
        Ce1{i} = SymFunction(['Ce1_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart1',{De,Qe,dQe,i}),{Qe,dQe});
        Ce2{i} = SymFunction(['Ce2_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart2',{De,Qe,dQe,i}),{Qe,dQe});
        Ce3{i} = SymFunction(['Ce3_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart3',{De,Qe,dQe,i}),{Qe,dQe});
    end
    
    % We add dQe as dependent variables to the gravity vector in order to have a same structure
    % as the corilios forces
    Ge = SymFunction(['Ge_vec_',obj.Name],eval_math_fun('GravityVector',{Qe,obj.SymLinks,obj.SymTwists}),{Qe,dQe});
    
    vf = [Ce1;Ce2;Ce3;{Ge}];
    
    obj.setDriftVector(vf);
end