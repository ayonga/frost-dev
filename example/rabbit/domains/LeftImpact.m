% Left Foot Impact (guard)
function guard = LeftImpact(domain1, domain2)
    
    % set impact
    guard = RigidImpact('LeftImpact',domain1,'rightFootHeight');
    
    % Relabeling Matrix
    guard.R = guard.R(:,[1:3,6:7,4:5]);
    
    % set the impact constraint
    guard.addImpactConstraint(struct2array(domain2.HolonomicConstraints));    
end