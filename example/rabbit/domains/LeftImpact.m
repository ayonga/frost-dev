% Left Foot Impact (guard)
function guard = LeftImpact(domain)
    
    % set impact
    guard = RigidImpact('LeftImpact',domain,'rightFootHeight');
    
    % Relabeling Matrix
    guard.R = guard.R(:,[1:3,6:7,4:5]);
    
    % set the impact constraint
    guard.addImpactConstraint(struct2array(domain.HolonomicConstraints));    
end