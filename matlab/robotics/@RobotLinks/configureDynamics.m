function obj = configureDynamics(obj, varargin)
    % Set the symbolic expressions of the dynamics of the rigid body system
    %
    % Parameters:
    % varargin: extra options @type varargin
    
    opts = struct(varargin{:});
    if isfield(opts, 'DelayCoriolisSet')
        delay_set = opts.DelayCoriolisSet;
    else
        delay_set = false;
    end
    
    n_link = length(obj.Links);
    links = getTwists(obj.Links);
    for i=1:n_link
        links{i}.Mass = obj.Links(i).Mass;
        links{i}.Inertia = obj.Links(i).Inertia;   
    end
    
    % set the inertia matrix 
    tic
    De = eval_math_fun('InertiaMatrix',[links,{obj.numState}]);
    toc
    obj.setMassMatrix(De);
    
    Qe = obj.States.x;
    dQe = obj.States.dx;
    
    %|@note !!! The minus sign !!!
    % Fvec appears at the right hand side (typically -C(q,dq)dq - G(q)
    % appears at the left hand side of the Euler-Lagrangian Equation)
    Ce1 = cell(obj.numState,1);
    Ce2 = cell(obj.numState,1);
    Ce3 = cell(obj.numState,1);
    tic
    for i=1:obj.numState
        Ce1{i} = SymFunction(['Ce1_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart1',{De,Qe,dQe,i},[],'DelayedSet',delay_set),{Qe,dQe});
        Ce2{i} = SymFunction(['Ce2_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart2',{De,Qe,dQe,i},[],'DelayedSet',delay_set),{Qe,dQe});
        Ce3{i} = SymFunction(['Ce3_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart3',{De,Qe,dQe,i},[],'DelayedSet',delay_set),{Qe,dQe});
    end
    toc
    % We add dQe as dependent variables to the gravity vector in order to have a same structure
    % as the corilios forces
    Ge = SymFunction(['Ge_vec_',obj.Name],-eval_math_fun('GravityVector',[links,{Qe}]),{Qe,dQe});
    
    vf = [Ce1;Ce2;Ce3;{Ge}];
    tic
    obj.setDriftVector(vf);
    toc
end