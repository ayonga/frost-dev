 % Left Stance Domain 
 %
 % Contact: Left Sole (planar)
function domain = LeftStance(model)
    % construct the left stance domain of the ATLAS
    % flat-footed walking
    %
    % Parameters:
    % model: the right body model of ATLAS robot
    
    %% first make a copy of the robot model
    %| @note Do not directly assign with the model variable, since it is a
    %handle object.
    domain = copy(model);
    % set the name of the new copy
    domain.setName('LeftStance');
    
    % add contact
    left_sole = ContactFrame(domain.ContactPoints.LeftSole,...
        'PlanarContactWithFriction');
    fric_coef.mu = 0.6;
    fric_coef.gamma = 100;
    geometry.la = domain.wf/2;
    geometry.lb = domain.wf/2;
    geometry.La = domain.lt;
    geometry.Lb = domain.lh;
    domain = addContact(domain,left_sole,fric_coef,geometry);
    
    % add event
    % height of non-stance foot (left sole)
    p_nsf = getCartesianPosition(domain, domain.ContactPoints.RightSole);
    h_nsf = UnilateralConstraint(domain,p_nsf(3),'nsf','x');
    domain = addEvent(domain, h_nsf);
    
    % the origin of the right hip link frame (not the CoM position)
    x = domain.States.x;
    dx = domain.States.dx;
    
    
    % phase variable: linearized hip position
    %     l_hip_link = domain.Links(getLinkIndices(domain, 'r_uleg'));
    %     l_hip_frame = l_hip_link.Reference;
    l_hip_frame = domain.Joints(getJointIndices(domain,'l_leg_hpy'));
    l_ankle_frame = domain.Joints(getJointIndices(domain,'l_leg_aky'));
    p_lhp = getCartesianPosition(domain, l_hip_frame); 
    p_lak = getCartesianPosition(domain, l_ankle_frame);
    % p_sf = getCartesianPosition(domain, domain.ContactPoints.LeftSole);
    
    
    p_hip = p_lhp(1) - p_lak(1);
    deltaPhip = linearize(p_hip,x);
    p = SymVariable('p',[2,1]);
    tau = (deltaPhip-p(2))/(p(1)-p(2));
    
    % relative degree one output: linearized hip velocity
    v_hip = jacobian(deltaPhip, x)*dx;
    
    y1 = VirtualConstraint(domain,v_hip,'velocity','DesiredType','Constant',...
        'RelativeDegree',1,'OutputLabel',{'vhip'},'PhaseType','StateBased',...
        'PhaseVariable',tau,'PhaseParams',p,'Holonomic',false);
    
    
    
    % relative degree two outputs:
    
    y_lar = x('l_leg_akx');
    y_lkp = x('l_leg_kny');
    y_ltp = -x('l_leg_aky') - x('l_leg_kny') - x('l_leg_hpy');
    y_ltr = -x('l_leg_akx') - x('l_leg_hpx');
    y_lhy = x('l_leg_hpz');
    y_rkp = x('r_leg_kny');
    y_rlr = x('l_leg_hpx') - x('r_leg_hpx');
    
    r_hip_frame = domain.Joints(getJointIndices(domain,'r_leg_hpy'));
    r_ankle_frame = domain.Joints(getJointIndices(domain,'r_leg_aky'));
    [p_lhp,p_lak] = getCartesianPosition(domain, r_hip_frame, r_ankle_frame);
    % p_lak = getCartesianPosition(domain, r_ankle_frame);
    nsl = (p_lak(1) - p_lhp(1))/(p_lak(3) - p_lhp(3));
    y_nsl = linearize(nsl,x);
    
    p_rsi = getCartesianPosition(domain, domain.ContactPoints.RightSoleInside);
    p_rso = getCartesianPosition(domain, domain.ContactPoints.RightSoleOutside);
    p_rtoe = getCartesianPosition(domain, domain.ContactPoints.RightToe);
    p_rheel = getCartesianPosition(domain, domain.ContactPoints.RightHeel);
    
    y_rfr = p_rsi(3) - p_rso(3);
    y_rfp = p_rheel(3) - p_rtoe(3);
    y_rfy = p_rheel(2) - p_rtoe(2);
    
    ya_2 = [y_lar;
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
    
    y2_label = {'LeftAnkleRoll',...
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
    
    y2 = VirtualConstraint(domain,ya_2,'position','DesiredType','Bezier','PolyDegree',5,...
        'RelativeDegree',2,'OutputLabel',{y2_label},'PhaseType','StateBased',...
        'PhaseVariable',tau,'PhaseParams',p,'Holonomic',true);
    
    
    domain = addVirtualConstraint(domain,y1);
    domain = addVirtualConstraint(domain,y2);
end
    