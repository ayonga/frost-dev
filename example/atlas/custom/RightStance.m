 % Right Stance Domain 
 %
 % Contact: Right Sole (planar)
function domain = RightStance(model)
    % construct the right stance domain of the ATLAS
    % flat-footed walking
    %
    % Parameters:
    % model: the right body model of ATLAS robot
    
    %% first make a copy of the robot model
    %| @note Do not directly assign with the model variable, since it is a
    %handle object.
    domain = copy(model);
    % set the name of the new copy
    domain.setName('RightStance');
    
    % add contact
    right_sole = ToContactFrame(domain.ContactPoints.RightSole,...
        'PlanarContactWithFriction');
    fric_coef.mu = 0.6;
    fric_coef.gamma = 100;
    geometry.la = domain.wf/2;
    geometry.lb = domain.wf/2;
    geometry.La = domain.lt;
    geometry.Lb = domain.lh;
    domain = addContact(domain,right_sole,fric_coef,geometry);
    
    % add event
    % height of non-stance foot (left sole)
    p_nsf = getCartesianPosition(domain, domain.ContactPoints.LeftSole);
    h_nsf = UnilateralConstraint(domain,p_nsf(3),'nsf','x');
    
    domain = addEvent(domain, h_nsf);
    
    % the origin of the right hip link frame (not the CoM position)
    x = domain.States.x;
    dx = domain.States.dx;
    
    
    % phase variable: linearized hip position
    %     r_hip_link = domain.Links(getLinkIndices(domain, 'l_uleg'));
    %     r_hip_frame = r_hip_link.Reference;
    r_hip_frame = domain.Joints(getJointIndices(domain,'r_leg_hpy'));
    r_ankle_frame = domain.Joints(getJointIndices(domain,'r_leg_aky'));
    p_rhp = getCartesianPosition(domain, r_hip_frame); 
    p_rak = getCartesianPosition(domain, r_ankle_frame);
    % p_sf = getCartesianPosition(domain, domain.ContactPoints.RightSole);
    
    
    p_hip = p_rhp(1) - p_rak(1);
    deltaPhip = linearize(p_hip,x);
    p = SymVariable('p',[2,1]);
    tau = (deltaPhip-p(2))/(p(1)-p(2));
    
    % relative degree one output: linearized hip velocity
    v_hip = jacobian(deltaPhip, x)*dx;
    
    y1 = VirtualConstraint(domain,v_hip,'velocity','DesiredType','Constant',...
        'RelativeDegree',1,'OutputLabel',{'vhip'},'PhaseType','StateBased',...
        'Holonomic',false);
    
    
    
    % relative degree two outputs:
    
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
    
    p_lsi = getCartesianPosition(domain, domain.ContactPoints.LeftSoleInside);
    p_lso = getCartesianPosition(domain, domain.ContactPoints.LeftSoleOutside);
    p_ltoe = getCartesianPosition(domain, domain.ContactPoints.LeftToe);
    p_lheel = getCartesianPosition(domain, domain.ContactPoints.LeftHeel);
    
    y_lfr = p_lsi(3) - p_lso(3);
    y_lfp = p_lheel(3) - p_ltoe(3);
    y_lfy = p_lheel(2) - p_ltoe(2);
    
    ya_2 = [y_rar;
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
    
    y2_label = {'RightAnkleRoll',...
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
    
    y2 = VirtualConstraint(domain,ya_2,'position','DesiredType','Bezier','PolyDegree',5,...
        'RelativeDegree',2,'OutputLabel',{y2_label},'PhaseType','StateBased',...
        'PhaseVariable',tau,'PhaseParams',p,'Holonomic',true);
    
    
    domain = addVirtualConstraint(domain,y1);
    domain = addVirtualConstraint(domain,y2);
end
    