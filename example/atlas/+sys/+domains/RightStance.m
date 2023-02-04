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
    domain.Name = 'RightStance';
    
    if nargin < 2
        load_path = [];
    end
    
    
    %% Add contact
    % left foot point contact
    [right_foot, fric_coef,geometry] = sys.frames.RightSole(model);
    right_foot_contact = ToContactFrame(right_foot,...
        'PlanarContactWithFriction');
    domain = addContact(domain,right_foot_contact,fric_coef,geometry,load_path);
    
    %% Add event
    % height of non-stance foot (left toe)
    [left_foot] = sys.frames.LeftSole(model);
    p_swingFoot = getCartesianPosition(domain, left_foot);
    h_nsf_fun = SymFunction('leftfoot_height',p_swingFoot(3),{domain.States.x});
    h_nsf_constr = EventFunction(h_nsf_fun, domain);
    domain = addEvent(domain, h_nsf_constr);
   
    %% Add Virtual Constraints
    x = domain.States.x;
    dx = domain.States.dx;
    
    
    % phase variable: linearized hip position
    %     r_hip_link = domain.Links(getLinkIndices(domain, 'l_uleg'));
    %     r_hip_frame = r_hip_link.Reference;
    %     r_hip_frame = domain.Joints(getJointIndices(domain,'r_leg_hpy'));
    %     r_ankle_frame = domain.Joints(getJointIndices(domain,'r_leg_aky'));
    %     p_rhp = getCartesianPosition(domain, r_hip_frame);
    %     p_rak = getCartesianPosition(domain, r_ankle_frame);
    %     % p_sf = getCartesianPosition(domain, domain.ContactPoints.RightSole);
    %
    %
    %     p_hip = p_rhp(1) - p_rak(1);
    %     deltaPhip = linearize(p_hip,x);
    
    % @state based phase variable
    %     p = SymVariable('p',[2,1]);
    %     tau = (deltaPhip-p(2))/(p(1)-p(2));
    
    % @time based phase variable
    t = SymVariable('t');
    p = ParamVariable('pOutputs',[2,1],[0;0.25],[0;0.75]);
    tau = (t-p(1))/(p(2)-p(1));
    
    
    
    % relative degree two outputs:
    y_rap = x('r_leg_aky');
    y_rar = x('r_leg_akx');
    y_rkp = x('r_leg_kny');
    y_rtp = -x('r_leg_aky') - x('r_leg_kny') - x('r_leg_hpy');
    y_rtr = -x('r_leg_akx') - x('r_leg_hpx');
    y_rhy = x('r_leg_hpz');
    y_lkp = x('l_leg_kny');
    y_llr = x('r_leg_hpx') - x('l_leg_hpx');
    
    l_hip_frame = domain.Joints(getJointIndices(domain,'l_leg_hpy'));
    l_ankle_frame = domain.Joints(getJointIndices(domain,'l_leg_aky'));
    p_lhp = getCartesianPosition(domain, l_hip_frame);
    p_lak = getCartesianPosition(domain, l_ankle_frame);
    % p_lak = getCartesianPosition(domain, l_ankle_frame);
    nsl = (p_lak(1) - p_lhp(1))/(p_lak(3) - p_lhp(3));
    y_nsl = linearize(nsl,x);
    
    
    left_sole_inside = sys.frames.LeftSoleInside(model);
    left_sole_outside = sys.frames.LeftSoleOutside(model);
    left_toe = sys.frames.LeftToe(model);
    left_heel = sys.frames.LeftHeel(model);
    p_lsi = getCartesianPosition(domain, left_sole_inside);
    p_lso = getCartesianPosition(domain, left_sole_outside);
    p_ltoe = getCartesianPosition(domain, left_toe);
    p_lheel = getCartesianPosition(domain, left_heel);
    
    y_lfr = p_lsi(3) - p_lso(3);
    y_lfp = p_lheel(3) - p_ltoe(3);
    y_lfy = p_lheel(2) - p_ltoe(2);
    
    ya_2 = [y_rap;
        y_rar;
        y_rkp;
        y_rtp;
        y_rtr;
        y_rhy;
        y_lkp;
        y_nsl;
        y_llr;
        y_lfr;
        y_lfp;
        y_lfy];
    
    % optional
    y2_label = {'RightAnklePitch',...
        'RightAnkleRoll',...
        'RightKneePitch',...
        'RightTorsoPitch',...
        'RightTorsoRoll',...
        'RightHipYaw',...
        'LeftKneePitch',...
        'LeftLinNSlopeWithBase',...
        'LeftLegRoll',...
        'LeftFootCartX',...
        'LeftFootCartY',...
        'LeftFootCartZ'};

    y2 = VirtualConstraint('Outputs',ya_2,domain,...
        'OutputLabel',y2_label,...
        'DesiredType','Bezier',...
        'NumControlPoint',5,...
        'RelativeDegree',2,...
        'PhaseType','TimeBased',...
        'PhaseVariable',tau,...
        'PhaseParams',p,...
        'IsHolonomic',true);
    domain = addVirtualConstraint(domain,y2);
end
    