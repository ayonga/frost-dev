% Right Foot Impact (guard)
function guard = RightImpact(domain)
    
    
    guard = RigidImpact('RightImpact',domain,'nsf');
    
    % set the impact constraint
    guard.addImpactConstraint(struct2array(domain.HolonomicConstraints));
    
    
end