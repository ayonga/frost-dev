 % Right Stance Domain 
 %
 % Contact: Right Toe
function domain = RightStance(model, load_path)
    % construct the right stance domain of Cassie
    %
    % Parameters:
    % model: the right body model of Cassie robot
    
    %% first make a copy of the robot model
    %| @note Do not directly assign with the model variable, since it is a
    %handle object.
    domain = copy(model);
    % set the name of the new copy
    domain.setName('RightStance');
    
    % Extract state variables
    q = domain.States.x;
    
    if nargin < 2
        load_path = [];
    end
    
    
    %% Add contact
    % right foot point contact
    [right_foot, fric_coef] = sys.frames.RightFoot(model);    
    %     geom = [];
    %     domain = addContact(domain,right_foot,fric_coef, geom, load_path);
    p_right_foot = getCartesianPosition(domain, right_foot);
    r_right_foot = getRelativeEulerAngles(domain, right_foot);
    
    constr = [p_right_foot(1);p_right_foot(2);p_right_foot(3);r_right_foot(3)];
    hol = HolonomicConstraint(domain, constr, 'RightFoot',...
        'ConstrLabel',{{'RightFootX','RightFootY','RightFootZ','RightFootYaw'}},...
        'DerivativeOrder',2);
    domain = addHolonomicConstraint(domain,hol);
    if ~isempty(fric_coef)
        
        f = domain.Inputs.ConstraintWrench.fRightFoot;
        % get the friction cone constraint
        %         [friction_cone, fc_label, auxdata] = getFrictionCone(right_foot, f, fric_coef);
        mu = SymVariable('mu');
        gamma = SymVariable('gamma');
        % x, y, z, roll, yaw
        constr = [f(3) - 300; % fz >= 0
            f(1) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fx
            -f(1) + (mu/sqrt(2))*f(3); % fx < mu/sqrt(2) * fz
            f(2) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fu
            -f(2) + (mu/sqrt(2))*f(3); % fy < mu/sqrt(2) * fz
            f(4) + gamma * f(3);       % -gamma * fz < wy
            -f(4) + gamma * f(3)];     % wy < gamma * fz
        
        % create a symbolic function object
        friction_cone = SymFunction(['u_friction_cone_', right_foot.Name],...
            constr,{f},{[mu;gamma]});
        
        % create the label text
        fc_label = {'normal_force';
            'friction_x_pos';
            'friction_x_neg';
            'friction_y_pos';
            'friction_y_neg';
            'tor_firction_neg';
            'tor_firction_pos';
            };
        
        
        auxdata = [fric_coef.mu; fric_coef.gamma];
        
        
        % create an unilateral constraint object
        fc_cstr = UnilateralConstraint(domain, friction_cone,...
            ['fc' right_foot.Name], 'fRightFoot', ...
            'ConstrLabel',{fc_label(:)'},...
            'AuxData',auxdata);
        % add as a set of unilateral constraitns
        domain = addUnilateralConstraint(domain, fc_cstr);
    end
    
    %% Add event
    % height of non-stance foot (left toe)
    [left_foot_frame] = sys.frames.LeftFoot(model);
    p_swingFoot = getCartesianPosition(domain, left_foot_frame);
    h_nsf = UnilateralConstraint(domain,p_swingFoot(3),'leftFootHeight','x');
    domain = addEvent(domain, h_nsf);
   
    % phase variable: time
    t = SymVariable('t');
    p = SymVariable('p',[2,1]);
    tau = (t-p(1))/(p(2)-p(1));
    
    % relative degree two outputs:
    ya_2 = [q('qHRight');
        (q('qARight')+q('qBRight'))./2;
        -q('qARight')+q('qBRight');
        q('qHLeft');
        (q('qALeft')+q('qBLeft'))./2;
        -q('qALeft')+q('qBLeft');];
    
    
    y2 = VirtualConstraint(domain,ya_2,'output','DesiredType','Bezier','PolyDegree',5,...
        'RelativeDegree',2,'PhaseType','TimeBased',...
        'PhaseVariable',tau,'PhaseParams',p,'Holonomic',true, 'LoadPath', load_path);
    
    domain = addVirtualConstraint(domain,y2);
    
    
    domain.PreProcess = @sim.RightStancePreProcess;
end
    