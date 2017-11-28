function LeftStance1Constraints(nlp, bounds, varargin)
    domain = nlp.Plant;
    
    ip = inputParser;
    ip.addParameter('LoadPath',[],@ischar);
    ip.parse(varargin{:});
    
    %% virtual constraints    
    opt.constraint.virtual_constraints(nlp, bounds, ip.Results.LoadPath);
    %% foot clearance
    [right_foot_frame] = sys.frames.RightFoot(domain);
    opt.constraint.foot_clearance(nlp, bounds, right_foot_frame);
    
    %% swing toe position
%     trans_opt.constraint.step_distance(nlp, bounds);
    
    %% swing foot orientation
    %     opt.constraint.foot_orientation(nlp, bounds, 'Right');
    %% swing foot velocity
    opt.constraint.impact_velocity(nlp, bounds, right_foot_frame);
    
    
    %% feet distance
    %     opt.constraint.feet_distance(nlp, bounds);
    
    
    opt.constraint.yaw_start(nlp, bounds);
    
    opt.constraint.knee_angle(nlp, bounds);
    
%     opt.constraint.average_velocity(nlp, bounds);

    trans_opt.constraint.periodicity(nlp, floor(nlp.NumNode/2)+1, bounds);
end
