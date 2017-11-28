function RightStance2Constraints(nlp, bounds, varargin)
    
    ip = inputParser;
    ip.addParameter('LoadPath',[],@ischar);
    ip.parse(varargin{:});
    
    domain = nlp.Plant;
    
    %% virtual constraints    
    opt.constraint.virtual_constraints(nlp, bounds, ip.Results.LoadPath);
    %% foot clearance
    [left_foot_frame] = sys.frames.LeftFoot(domain);
    opt.constraint.foot_clearance(nlp, bounds, left_foot_frame);    
    
    %% swing toe position
    %     trans_opt.constraint.step_distance(nlp, bounds);
    
    %% swing foot velocity
    opt.constraint.impact_velocity(nlp, bounds, left_foot_frame);
    
    
    
    %% feet distance
    %     opt.constraint.feet_distance(nlp, bounds);
    
    opt.constraint.yaw_start(nlp, bounds);
    
    opt.constraint.knee_angle(nlp, bounds);
    
    %     opt.constraint.average_velocity(nlp, bounds);
    
    % trans_opt.constraint.periodicity(nlp, floor(nlp.NumNode/2)+1, bounds);
end
