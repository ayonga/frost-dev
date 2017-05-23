function obj = addContact(obj, contact, fric_coef, geometry)
    % Adds contact constraints for the robot manipulator
    %
    % Parameters:
    %  contact: the contact frame object @type ContactFrame
    %  fric_coef: the friction coefficient @type struct
    %  geometry: the geometry constant of the contact @type struct
    %
    % Optional fields of geometry:
    %  la: the distance from the origin to the rolling edge along
    %  the positive x-axis  @type double
    %  lb: the distance from the origin to the rolling edge along
    %  the negative x-axis  @type double    
    %  La: the distance from the origin to the rolling edge along
    %  the negative y-axis  @type double
    %  Lb: the distance from the origin to the rolling edge along
    %  the positive y-axis  @type double
    %  RefFrame: The frame describing the ground contact zero configuration.
    %
    % Optional fields of fric_coef:
    %  mu: the (static) coefficient of friction. @type double
    %  gamma: the coefficient of torsional friction @type double
    
    assert(isa(contact, 'ContactFrame'),...
        'The contact must be given as an object of ContactFrame class.');
    
    % Equivalent to grasp map in Murray Ch 5. Maps the wrench base into the
    % nominal contact reference frame.
    if nargin < 4 || (~isfield(geometry, 'RefFrame'))
        geometry.RefFrame = eye(3);
    end
    ref = geometry.RefFrame;
    G = [eye(3), zeros(3,3); zeros(3,3), ref] * contact.WrenchBase;
    
    % compute the spatial position (cartesian position + Euler angles)
    pos = getCartesianPosition(obj, contact);
    rpy = getRelativeEulerAngles(obj, contact, ref);
    
    h = transpose([pos, rpy]); %effectively as transpose
    % extract the contrained elements
    constr =  G' * h;
    % compute the body jacobian 
    jac = getSpatialJacobian(obj, contact);
    % extract the contrained elements
    constr_jac = contact.WrenchBase' * jac;
    
    % label for the holonomic constraint
    label_full = cellfun(@(x)[contact.Name,x],...
        {'PosX','PosY','PosZ','Roll','Pitch','Yaw'},'UniformOutput',false);
    for i=size(contact.WrenchBase,2):-1:1
        label{i} = label_full{find(contact.WrenchBase(:,i))};         %#ok<FNDSB>
    end
    
    % create a holonomic constraint object
    contact_constr = HolonomicConstraint(obj,...
        constr, contact.Name,...
        'Jacobian',constr_jac,...
        'ConstrLabel',{label},...
        'DerivativeOrder',2);
    
    % add as a set of holonomic constraints
    obj = addHolonomicConstraint(obj, contact_constr);
    % the contact wrench input vector
    f_name = contact_constr.InputName;
    f = obj.Inputs.ConstraintWrench.(f_name);
    
    
    % if the friction coefficients are given, enforce friction cone
    % constraints
    if nargin > 2
        % get the friction cone constraint
        [friction_cone, fc_label, auxdata] = getFrictionCone(contact, f, fric_coef);
        
        % create an unilateral constraint object
        fc_cstr = UnilateralConstraint(obj, friction_cone,...
            ['fc' contact.Name], f_name, ...
            'ConstrLabel',{fc_label(:)'},...
            'AuxData',auxdata);
        % add as a set of unilateral constraitns
        obj = addUnilateralConstraint(obj, fc_cstr);
    end
    
    % if the contact geometry is given, enforce zero moment point
    % constraints
    if nargin > 3
        % get the friction cone constraint
        [zmp, zmp_label, auxdata] = getZMPConstraint(contact, f, geometry);
        
        % create an unilateral constraint object
        zmp_cstr = UnilateralConstraint(obj, zmp,...
            ['zmp' contact.Name], f_name, ...
            'ConstrLabel',{zmp_label(:)'},...
            'AuxData',auxdata);
        % add as a set of unilateral constraitns
        obj = addUnilateralConstraint(obj, zmp_cstr);
        
    end
end
