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
    
    if isfield(opts, 'OmitCoriolisSet')
        omit_set = opts.OmitCoriolisSet;
    else
        omit_set = false;
    end
    
    
    n_link = length(obj.Links);
    links = getTwists(obj.Links);
    for i=1:n_link
        links{i}.Mass = obj.Links(i).Mass;
        links{i}.Inertia = obj.Links(i).Inertia;   
    end
    
    % set the inertia matrix 
    fprintf('Evaluating the inertia matrix D(q): \t');
    tic
    De = eval_math_fun('InertiaMatrix',[links,{obj.numState}]);
    
    De_motor = zeros(obj.numState);
    for i=1:obj.numState
        if ~isempty(obj.Joints(i).Actuator) 
            actuator = obj.Joints(i).Actuator;
            
            if ~isempty(actuator.Inertia) && ~isempty(actuator.Ratio)
                % reflected motor inertia: I*r^2
                De_motor(i,i) = actuator.Inertia * actuator.Ratio^2;
                
            end
        end
        
    end
    
    De_full = De + De_motor;
    obj.setMassMatrix(De_full);
    
    toc
    
    
    Qe = obj.States.x;
    dQe = obj.States.dx;
    
    %|@note !!! The minus sign !!!
    % Fvec appears at the right hand side (typically -C(q,dq)dq - G(q)
    % appears at the left hand side of the Euler-Lagrangian Equation)
    if omit_set
        tic
        fprintf('Evaluating the gravity vector G(q): \t');
        Ge = SymFunction(['Ge_vec_',obj.Name],-eval_math_fun('GravityVector',[links,{Qe}]),{Qe,dQe});
        toc
        vf = {Ge};
    else
        tic
        Ce1 = cell(obj.numState,1);
        Ce2 = cell(obj.numState,1);
        Ce3 = cell(obj.numState,1);
        m = 100;
        fprintf('Evaluating the coriolis term C(q,dq)dq: \t');
        bs = '\b';
        sp = ' ';
        msg = '%d percents completed…\n'; % carriage return included in case error interrupts loop
        msglen = length(msg)-3; % compensate for conversion character and carriage return
        fprintf(1,sp(ones(1,ceil(log10(m+1))+msglen)));
        for i=1:obj.numState
            k = floor(((i-1)*3+1)*100/(3*obj.numState));
            fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
            Ce1{i} = SymFunction(['Ce1_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart1',{De,Qe,dQe,i},[],'DelayedSet',delay_set),{Qe,dQe});
            k = floor(((i-1)*3+2)*100/(3*obj.numState));
            fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
            Ce2{i} = SymFunction(['Ce2_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart2',{De,Qe,dQe,i},[],'DelayedSet',delay_set),{Qe,dQe});
            k = floor(((i-1)*3+3)*100/(3*obj.numState));
            fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
            Ce3{i} = SymFunction(['Ce3_vec',num2str(i),'_',obj.Name],eval_math_fun('InertiaToCoriolisPart3',{De,Qe,dQe,i},[],'DelayedSet',delay_set),{Qe,dQe});
        end
        fprintf(1,sp(ones(1,40)));
        toc
        % We add dQe as dependent variables to the gravity vector in order to have a same structure
        % as the corilios forces
        tic
        fprintf('Evaluating the gravity vector G(q): \t');
        Ge = SymFunction(['Ge_vec_',obj.Name],-eval_math_fun('GravityVector',[links,{Qe}]),{Qe,dQe});
        toc
        vf = [Ce1;Ce2;Ce3;{Ge}];
    end
    
    obj.setDriftVector(vf);
    
end