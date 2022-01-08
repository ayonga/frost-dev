function obj = configureDynamics(obj, load_path)
    % Set the symbolic expressions of the dynamics of the rigid body system
    %
    % Parameters:
    % varargin: extra options @type varargin
    
    if nargin < 2
        load_path = [];
    end
    
    
    n_link = length(obj.Links);
    links = getTwists(obj.Links);
    for i=1:n_link
        links{i}.Mass = obj.Links(i).Mass;
        links{i}.Inertia = obj.Links(i).Inertia;   
    end
    
    % set the inertia matrix 
    tic
    %     De = eval_math_fun('InertiaMatrix',[links,{obj.Dimension}]);
    n_link = length(links);
    De = cell(n_link,1);
    m = 100;
    fprintf('Computing symbolic expression of the inertia matrix D(q): \t');
    bs = '\b';
    sp = ' ';
    msg = '%d percents completed.\n'; % carriage return included in case error interrupts loop
    msglen = length(msg)-3; % compensate for conversion character and carriage return
    fprintf(1,sp(ones(1,ceil(log10(m+1))+msglen)));
    
    for i=1:n_link        
        M = eval_math_fun('InertiaMatrixByLink',[links(i),{obj.Dimension}]);
        De{i} = SymFunction(['Mmat_L',num2str(i),'_',obj.Name], M, {obj.States.x});
        k = floor(i*100/n_link);
        fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
    end
    
    M_motor = zeros(obj.Dimension);
    GearRatio = zeros(1,obj.Dimension);
    for i=1:obj.Dimension
        if ~isempty(obj.Joints(i).Actuator) 
            actuator = obj.Joints(i).Actuator;
            GearRatio(i) = actuator.GearRatio;
            if ~isempty(actuator.RotorInertia) && ~isempty(actuator.GearRatio)
                % reflected motor inertia: I*r^2
                M_motor(i,i) = actuator.RotorInertia * actuator.GearRatio^2;                
            end
        end        
    end
    De_motor = SymFunction(['Mmat_Rotor_',obj.Name], SymExpression(M_motor), {obj.States.x});
    %     fprintf(1,sp(ones(1,40)));
    Mmat_full = [De; {De_motor}];
    obj.setMassMatrix(Mmat_full{:});
    
    toc
    
    
    
    
    actuated_joints = obj.Joints(GearRatio~=0);
    nact = length(actuated_joints);
    
    gf = zeros(obj.Dimension, nact);
    gf(GearRatio~=0,:) = diag(GearRatio(GearRatio~=0));
    
    limits = [obj.Joints.Limit];
    effort = [limits.effort];
    u = InputVariable('torque',nact,-transpose(effort(GearRatio~=0)),transpose(effort(GearRatio~=0)),'Control');
    setLabel(u, {actuated_joints.Name});
    setGmap(u, gf,obj);
    obj.addInput(u);
    
    
    %     obj.setDriftVector(vf);
    
end