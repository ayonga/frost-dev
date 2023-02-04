 % Left Stance Domain 
 %
 % Contact: Left Toe
function domain = LeftStance(model, load_path)
    % construct the right stance domain of Cassie
    %
    % Parameters:
    % model: the right body model of Cassie robot
    
    %% first make a copy of the robot model
    %| @note Do not directly assign with the model variable, since it is a
    %handle object.
    domain = copy(model);
    % set the name of the new copy
    domain.Name = 'LeftStance';
    
    
    if nargin < 2
        load_path = [];
    end
    
    %% Add contact
    % left foot point contact
    [left_foot, fric_coef,geometry] = sys.frames.LeftSole(model);
    left_foot_contact = ToContactFrame(left_foot,...
        'PlanarContactWithFriction');
    domain = addContact(domain,left_foot_contact,fric_coef,geometry,load_path);
    
    
    
    %% Add event
    % height of non-stance foot (left toe)
    [right_foot] = sys.frames.RightSole(model);
    p_swingFoot = getCartesianPosition(domain, right_foot);
    h_nsf_fun = SymFunction('rightfoot_height',p_swingFoot(3),{domain.States.x});
    h_nsf_constr = EventFunction(h_nsf_fun, domain);
    domain = addEvent(domain, h_nsf_constr);
   
    %% Add Virtual Constraints
    x = domain.States.x;
    dx = domain.States.dx;
    
    
    % phase variable: linearized hip position
    %     l_hip_link = domain.Links(getLinkIndices(domain, 'r_uleg'));
    %     l_hip_frame = l_hip_link.Reference;
    %     l_hip_frame = domain.Joints(getJointIndices(domain,'l_leg_hpy'));
    %     l_ankle_frame = domain.Joints(getJointIndices(domain,'l_leg_aky'));
    %     p_lhp = getCartesianPosition(domain, l_hip_frame);
    %     p_lak = getCartesianPosition(domain, l_ankle_frame);
    %     p_hip = p_lhp(1) - p_lak(1);
    %     deltaPhip = linearize(p_hip,x);
    
    % @state based phase variable
    %     p = SymVariable('p',[2,1]);
    %     tau = (deltaPhip-p(2))/(p(1)-p(2));
    
    % @time based phase variable
    t = SymVariable('t');
    p = ParamVariable('pOutputs',[2,1],[0;0.25],[0;0.75]);
    tau = (t-p(1))/(p(2)-p(1));
    
    
    
    
    
    % relative degree two outputs:
    y_lap = x('l_leg_aky');
    y_lar = x('l_leg_akx');
    y_lkp = x('l_leg_kny');
    y_ltp = -x('l_leg_aky') - x('l_leg_kny') - x('l_leg_hpy');
    y_ltr = -x('l_leg_akx') - x('l_leg_hpx');
    y_lhy = x('l_leg_hpz');
    y_rkp = x('r_leg_kny');
    y_rlr = x('l_leg_hpx') - x('r_leg_hpx');
    
    r_hip_frame = domain.Joints(getJointIndices(domain,'r_leg_hpy'));
    r_ankle_frame = domain.Joints(getJointIndices(domain,'r_leg_aky'));
    [p_lhp] = getCartesianPosition(domain, r_hip_frame);
    [p_lak] = getCartesianPosition(domain, r_ankle_frame);
    % p_lak = getCartesianPosition(domain, r_ankle_frame);
    nsl = (p_lak(1) - p_lhp(1))/(p_lak(3) - p_lhp(3));
    y_nsl = linearize(nsl,x);
    
    right_sole_inside = sys.frames.RightSoleInside(model);
    right_sole_outside = sys.frames.RightSoleOutside(model);
    right_toe = sys.frames.RightToe(model);
    right_heel = sys.frames.RightHeel(model);
    p_rsi = getCartesianPosition(domain, right_sole_inside);
    p_rso = getCartesianPosition(domain,right_sole_outside);
    p_rtoe = getCartesianPosition(domain, right_toe);
    p_rheel = getCartesianPosition(domain, right_heel);
    
    y_rfr = p_rsi(3) - p_rso(3);
    y_rfp = p_rheel(3) - p_rtoe(3);
    y_rfy = p_rheel(2) - p_rtoe(2);
    
    ya_2 = [y_lap;
        y_lar;
        y_lkp;
        y_ltp;
        y_ltr;
        y_lhy;
        y_rkp;
        y_nsl;
        y_rlr;
        y_rfr;
        y_rfp;
        y_rfy];

    y2_label = {'LeftAnklePitch',...
        'LeftAnkleRoll',...
        'LeftKneePitch',...
        'LeftTorsoPitch',...
        'LeftTorsoRoll',...
        'LeftHipYaw',...
        'RightKneePitch',...
        'RightLinNSlopeWithBase',...
        'RightLegRoll',...
        'RightFootCartX',...
        'RightFootCartY',...
        'RightFootCartZ'};

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
    