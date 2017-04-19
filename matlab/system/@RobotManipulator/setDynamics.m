function obj = setDynamics(obj)
    % Set the symbolic expressions of the dynamics of the rigid body system
    %
    
    
    n_link = length(obj.Links);
    links = cell(1,n_link);
    for i=1:n_link
        links{i}.Mass = obj.Links(i).Mass;
        links{i}.Inertia = obj.Links(i).Inertia;        
        links{i}.gst0 = obj.Links(i).gst0;
        frame = obj.Links(i).Reference;
        while isempty(frame.TwistPairs)
            frame = frame.Reference;
            if isempty(frame)
                error('The coordinate system is not fully defined.');
            end
        end
        
        links{i}.TwistPairs = frame.TwistPairs;
        links{i}.ChainIndices = frame.ChainIndices;
    end
    
    % set the inertia matrix 
    De = eval_math_fun('InertiaMatrix',[links,{obj.numState}]);
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
    Ge = SymFunction(['Ge_vec_',obj.Name],eval_math_fun('GravityVector',[links,{Qe}]),{Qe,dQe});
    
    vf = [Ce1;Ce2;Ce3;{Ge}];
    
    obj.setDriftVector(vf);
end