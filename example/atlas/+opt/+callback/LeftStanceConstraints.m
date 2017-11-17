function LeftStanceConstraints(nlp, bounds, varargin)
    domain = nlp.Plant;
    
    ip = inputParser;
    ip.addParameter('LoadPath',[],@ischar);
    ip.parse(varargin{:});
    
    %% virtual constraints    
    opt.constraint.virtual_constraints(nlp, bounds, ip.Results.LoadPath);
    
    opt.constraint.output_boundary_left(nlp, bounds);
    %% foot clearance
    [right_foot_frame] = sys.frames.RightSole(domain);
    opt.constraint.foot_clearance(nlp, bounds, right_foot_frame);
    
    %% swing toe position
    opt.constraint.step_distance(nlp, bounds);
    
    %% swing foot velocity
    opt.constraint.impact_velocity(nlp, bounds, right_foot_frame);
    
    
    
    opt.constraint.yaw_start(nlp, bounds);
    
    
    opt.constraint.average_velocity(nlp, bounds);
    
end
