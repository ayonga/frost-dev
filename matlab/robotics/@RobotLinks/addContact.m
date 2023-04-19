function obj = addContact(obj, contact, fric_coef, geometry, load_path)
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
    
    if nargin < 3
        fric_coef = [];
    end
    % Equivalent to grasp map in Murray Ch 5. Maps the wrench base into the
    % nominal contact reference frame.
    if nargin < 4 
        geometry = [];
        if ((~isfield(geometry, 'RefFrame')) && ~isempty(geometry))
            geometry.RefFrame = eye(3);
        end
    end
    
    if nargin < 5
       load_path = []; 
    end
    
    if isempty(load_path)
        if isempty(geometry) || ~isfield(geometry, 'RefFrame')
            ref = eye(3);
        else
            ref = geometry.RefFrame;
        end
        G = [eye(3), zeros(3,3); zeros(3,3), ref] * contact.WrenchBase;
        
        % compute the spatial position (cartesian position + Euler angles)
        pos = getCartesianPosition(obj, contact);
        if strcmp(contact.Type,'PointContactWithFriction') || strcmp(contact.Type,'PointContactWithoutFriction')
            rpy = SymExpression([0,0,0]);
        else
            rpy = getRelativeEulerAngles(obj, contact, ref);
        end
        %         rpy = getEulerAngles(obj, contact);
        
        h = transpose([pos, rpy]); %effectively as transpose
        % extract the contrained elements
        constr =  G' * h;
        % compute the body jacobian
        jac = getBodyJacobian(obj, contact);
        %         if strcmp(contact.Type,'PointContactWithFriction') || strcmp(contact.Type,'PointContactWithoutFriction')
        %             jac_pos = jacobian(pos,obj.States.x); % directly use partial derivatives for position
        %             jac = [jac_pos;jac_rot(4:6,:)];
        %         else
        %             jac = jac_rot;
        %         end
        %         extract the contrained elements
        idx = sum(contact.WrenchBase,2);
        constr_jac = jac(find(idx),:); %#ok<FNDSB>
        
    else
        
        % create an empty holonomic constraint object first with correct
        % name        
        h = SymFunction(['h_',contact.Name,'_',obj.Name],[],{obj.States.x});
        constr = load(h,load_path);
        Jh = SymFunction(['Jh_',contact.Name,'_',obj.Name],[],{obj.States.x});
        constr_jac = load(Jh,load_path);
    end
    
    % label for the holonomic constraint
    label_full = cellfun(@(x)[contact.Name,x],...
        {'PosX','PosY','PosZ','Roll','Pitch','Yaw'},'UniformOutput',false);
    for i=size(contact.WrenchBase,2):-1:1
        label{i} = label_full{find(contact.WrenchBase(:,i))};         %#ok<FNDSB>
    end
    contact_constr = HolonomicConstraint(contact.Name,...
        constr, obj,...
        'Jacobian',constr_jac,...
        'ConstrLabel',{label},...
        'RelativeDegree',2,...
        'LoadPath',load_path);
    % add as a set of holonomic constraints
    obj = addHolonomicConstraint(obj, contact_constr);
    % the contact wrench input vector
    f_name = contact_constr.f_name;
    f = obj.Inputs.(f_name);
    
    
    % if the friction coefficients are given, enforce friction cone
    % constraints
    if ~isempty(fric_coef)
        % get the friction cone constraint
        [friction_cone, fc_label, auxdata] = getFrictionCone(contact, f, fric_coef);
        
        % create an unilateral constraint object
        fc_cstr = UnilateralConstraint(friction_cone, obj,...
            'ConstrLabel',fc_label,...
            'AuxData',auxdata);
        % add as a set of unilateral constraitns
        obj = addUnilateralConstraint(obj, fc_cstr);
    end
    
    % if the contact geometry is given, enforce zero moment point
    % constraints
    if ~isempty(geometry)
        % get the friction cone constraint
        [zmp, zmp_label, auxdata] = getZMPConstraint(contact, f, geometry);
        
        % create an unilateral constraint object
        if ~isempty(zmp)
            zmp_cstr = UnilateralConstraint(zmp, obj,...
                'ConstrLabel',zmp_label,...
                'AuxData',auxdata);
            % add as a set of unilateral constraitns
            obj = addUnilateralConstraint(obj, zmp_cstr);
        end
    end
end
