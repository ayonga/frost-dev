function RightStanceConstraints(nlp, bounds)
    
    
    
    domain = nlp.Plant;
    load_path = nlp.Options.LoadPath;

    %% virtual constraints    
    opt.constraint.virtual_constraints(nlp, bounds, load_path);
    
    opt.constraint.output_boundary_right(nlp, bounds);
    %% foot clearance
    [left_foot_frame] = sys.frames.LeftSole(domain);
    opt.constraint.foot_clearance(nlp, bounds, left_foot_frame);    
    
    %% swing toe position
    opt.constraint.step_distance(nlp, bounds);
    
    %% swing foot velocity
    opt.constraint.impact_velocity(nlp, bounds, left_foot_frame);
    
    
    
    
    opt.constraint.yaw_start(nlp, bounds);
    
    
    opt.constraint.average_velocity(nlp, bounds);
end
