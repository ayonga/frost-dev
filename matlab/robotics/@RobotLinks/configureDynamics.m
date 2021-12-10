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
    tic
    %     De = eval_math_fun('InertiaMatrix',[links,{obj.numState}]);
    n_link = length(links);
    De = cell(n_link,1);
    m = 100;
    fprintf('Evaluating the inertia matrix D(q): \t');
    bs = '\b';
    sp = ' ';
    msg = '%d percents completed.\n'; % carriage return included in case error interrupts loop
    msglen = length(msg)-3; % compensate for conversion character and carriage return
    fprintf(1,sp(ones(1,ceil(log10(m+1))+msglen)));
    
    for i=1:n_link
        k = floor(i*100/n_link);
        fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
        De{i} = eval_math_fun('InertiaMatrixByLink',[links(i),{obj.numState}]);
    end
    
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
    
    %     fprintf(1,sp(ones(1,40)));
    Mmat_full = [De; {De_motor}];
    obj.setMassMatrix(Mmat_full);
    
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
        n_mass_mat = numel(obj.Mmat);
        n_dof      = obj.numState;
        Ce1 = cell(n_mass_mat*n_dof,1);
        Ce2 = cell(n_mass_mat*n_dof,1);
        Ce3 = cell(n_mass_mat*n_dof,1);
        m = 100;
        fprintf('Evaluating the coriolis term C(q,dq)dq: \t');
        bs = '\b';
        sp = ' ';
        msg = '%d percents completed.\n'; % carriage return included in case error interrupts loop
        msglen = length(msg)-3; % compensate for conversion character and carriage return
        fprintf(1,sp(ones(1,ceil(log10(m+1))+msglen)));
        for i=1:n_mass_mat
            for j=1:n_dof
                k = floor(((i-1)*3+(j-1)+1)*100/(3*n_mass_mat*n_dof));
                fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
                Ce1{(i-1)*n_dof+j} = SymFunction(...
                    ['Ce1_vec_L',num2str(i),'_J',num2str(j),'_', obj.Name],...
                    eval_math_fun('InertiaToCoriolisPart1New',{Mmat_full{i},Qe,dQe,j},[],'DelayedSet',delay_set),...
                    {Qe,dQe});
                k = floor(((i-1)*3+(j-1)+2)*100/(3*n_mass_mat*n_dof));
                fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
                Ce2{(i-1)*n_dof+j} = SymFunction(...
                    ['Ce2_vec_L',num2str(i),'_J',num2str(j),'_', obj.Name],...
                    eval_math_fun('InertiaToCoriolisPart2New',{Mmat_full{i},Qe,dQe,j},[],'DelayedSet',delay_set),...
                    {Qe,dQe});
                k = floor(((i-1)*3+(j-1)+3)*100/(3*n_mass_mat*n_dof));
                fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
                Ce3{(i-1)*n_dof+j} = SymFunction(...
                    ['Ce3_vec_L',num2str(i),'_J',num2str(j),'_', obj.Name],...
                    eval_math_fun('InertiaToCoriolisPart3New',{Mmat_full{i},Qe,dQe,j},[],'DelayedSet',delay_set),...
                    {Qe,dQe});
            end
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