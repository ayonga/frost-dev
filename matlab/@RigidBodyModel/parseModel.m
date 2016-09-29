function obj = parseModel(obj, robot)
    % Parse the robot struct from URDF file into rigid body model
    %
    % Parameters:
    %  robot: the URDF robot model @type struct
    %  options: a struct that specifies custom options of the model
    %
    % Return values:
    %  obj:   the object of this class
    
    % check the required elements in urdf.robot
    assert(isfield(robot,'joints'),...
        'The joints field is missing from the robot.');
    assert(isfield(robot,'links'),...
        'The links field is missing from the robot.');
    
    assert(~isempty(robot.joints),...
        'The joints field is empty');
    assert(~isempty(robot.links),...
        'The links field is empty');
   
    obj.joints = robot.joints;
    obj.links  = robot.links;
    
    options = obj.options;

    if options.use_floating_base
        switch options.floating_base_type
            case 'spatial'
                obj.nBase = 6;
            case 'planar'
                obj.nBase = 3;
        end
    end;

    obj.nDof = obj.nBase + numel(obj.joints);
        
    % Setup indices for fast operator
    obj = configureIndices(obj);
    
    % configure SVA
    obj.sva = configureSVA(obj);


end