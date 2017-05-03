% Left Foot Impact (guard)
function guard = LeftImpactRelabel(domain)
    
    
    guard = RigidImpact('LeftImpact',domain,'nsf');
    
    %     frame = domain.ContactPoints.LeftSole;
    %     pos = getCartesianPosition(domain, frame);
    %     rpy = getEulerAngles(domain, frame);
    %     h = tomatrix([pos; rpy]); %effectively as transpose
    %     jac = getBodyJacobian(domain, frame);
    %     impact_cstr = HolonomicConstraint(domain,h, 'LeftSoleImpact',...
    %         'Jacobian',jac,...
    %         'DerivativeOrder',2);
    %
    guard.addImpactConstraint(domain.HolonomicConstraints.RightSole);
    guard.addImpactConstraint(domain.HolonomicConstraints.qfixed);
    % set the impact constraint
    %     guard.addImpactConstraint(struct2array(domain.HolonomicConstraints));
    
    
    jointName = {domain.Joints.Name};

    
    qbIndices = 1:6;
    % Indices of waist joints
    qWaistIndices = find(strncmpi(jointName,'back_',5)+strncmpi(jointName,'Torso',5));
    
    % Indices of right leg (arm) joints
    qRLegIndices = find(strncmpi(jointName,'r_leg',5));

    % Indices of left leg (arm) joints
    qLLegIndices = find(strncmpi(jointName,'l_leg',5));

    swappingIndices = cumsum(ones(domain.numState,1));
    swappingIndices(qbIndices)     = qbIndices;
    swappingIndices(qWaistIndices) = qWaistIndices;
    swappingIndices(qRLegIndices)  = qLLegIndices;
    swappingIndices(qLLegIndices)  = qRLegIndices;

    % find roll joints of both legs
    rollJoints = strfind(jointName,...
        'x');
    rollJointIndices = [qbIndices(4),...
        find(~cellfun(@isempty,rollJoints))];
    
    
    % find yaw joints of both legs
    yawJoints = strfind(jointName,...
        'z');
    yawJointIndices = [qbIndices(6),...
        find(~cellfun(@isempty,yawJoints))];
    
    swappingSign = ones(domain.numState,1);
    swappingSign(qbIndices(2)) = -1; % switch sign of y axis position
    swappingSign(rollJointIndices) = -1*ones(numel(rollJointIndices),1);
    swappingSign(yawJointIndices) = -1*ones(numel(yawJointIndices),1);
    
    relabel = diag(swappingSign);
    R = relabel(swappingIndices,:);
    %     R(1:2,1:2) = zeros(2);
    
    guard.R = R;
end