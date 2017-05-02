% Left Foot Impact (guard)
function guard = LeftImpact(domain)
    
    
    guard = RigidImpact('LeftImpact',domain,'nsf');
    
    % set the impact constraint
    guard.addImpactConstraint(struct2array(domain.HolonomicConstraints));
    
    
end