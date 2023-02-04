function DoubleStanceConstraints(nlp, bounds, varargin)
    
    ip = inputParser;
    ip.addParameter('LoadPath',[],@ischar);
    ip.parse(varargin{:});
    
    domain = nlp.Plant;
    
   
    
    
    %% step distance
    opt.constraint.step_distance(nlp, bounds);
    
    opt.constraint.yaw_start(nlp, bounds);
    
end
