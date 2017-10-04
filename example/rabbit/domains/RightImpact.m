% Right Foot Impact (guard)
function guard = RightImpact(domain, load_path)
    
    % set impact
    guard = RigidImpact('RightImpact',domain,'leftFootHeight');
    
    % Relabeling Matrix
    guard.R = guard.R(:,[1:3,6:7,4:5]);
    
    % set the impact constraint
    % we will compute the impact map every time you add an impact
    % constraints, so it would be helpful to load expressions directly
    guard.addImpactConstraint(struct2array(domain.HolonomicConstraints), load_path);
end