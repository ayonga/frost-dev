% Right Foot Impact (guard)
function guard = RightImpact(domain1, domain2)
    
    % set impact
    guard = RigidImpact('RightImpact',domain1,'leftFootHeight');
    
    % Relabeling Matrix
    guard.R = guard.R(:,[1:3,6:7,4:5]);
    
    % set the impact constraint
    guard.addImpactConstraint(struct2array(domain2.HolonomicConstraints));
end