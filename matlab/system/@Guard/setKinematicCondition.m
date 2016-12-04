function obj = setKinematicCondition(obj, kin)
    % Sets a kinematic type of guard condition
    %
    % Parameters:
    % kin: a Kinematic function that defines the guard condition
    % @type Kinematics
    
    
    
    assert(isa(kin,'Kinematics'),...
        'Guard:invalidType',...
        'The input must be a Kinematics object');
    
    obj.kin = kin;
    
    % default function names
    obj.funcs.pos = ['guard_',obj.name];
    obj.funcs.jac = ['Jguard_',obj.name];
    
    
end
