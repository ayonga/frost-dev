function obj = parseModel(obj, model, options)
    % Parse the robot struct from URDF file into rigid body model
    %
    % Parameters:
    %  robot: the URDF robot model @type struct
    %  options: a struct that specifies custom options of the model
    %
    % Return values:
    %  obj:   the object of this class
    
    % check the required elements in robot
    assert(isfield(model,'name'),...
        'The name field is missing from the robot.');
    assert(isfield(model,'joints'),...
        'The joints field is missing from the robot.');
    assert(isfield(model,'links'),...
        'The links field is missing from the robot.');
    
    assert(~isempty(model.joints),...
        'The joints field is empty');
    assert(~isempty(model.links),...
        'The links field is empty');
   
    obj.name   = model.name;
    obj.joints = model.joints;
    obj.links  = model.links;
    
    

    if options.use_base_joint
        switch options.base_joint_type
            case 'floating'
                obj.nBase = 6;
            case 'planar'
                obj.nBase = 3;
            case 'fixed'
                obj.nBase = 0;
            case {'revolute', 'prismatic', 'continuous'}
                obj.nBase = 1;
            otherwise
                error('Unsupported joint type');
        end
    end;

    obj.nDof = obj.nBase + numel(obj.joints);
        
    % Setup indices for fast operator
    obj = configureIndices(obj);
    
    % configure SVA
    obj.sva = configureSVA(obj);


end