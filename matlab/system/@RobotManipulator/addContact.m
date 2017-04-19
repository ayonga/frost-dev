function obj = addContact(obj, contact, mu, gamma, la, lb, La, Lb)
    % Adds contact constraints for the robot manipulator
    %
    % Parameters:
    %  contact: the contact frame object @type ContactFrame
    %  mu: the (static) coefficient of friction. @type double
    %  gamma: the coefficient of torsional friction @type double
    %  la: the distance from the origin to the rolling edge along
    %  the negative y-axis  @type double
    %  lb: the distance from the origin to the rolling edge along
    %  the positive y-axis  @type double    
    %  La: the distance from the origin to the rolling edge along
    %  the negative x-axis  @type double
    %  Lb: the distance from the origin to the rolling edge along
    %  the positive x-axis  @type double
    
    assert(isa(contact, 'ContactFrame'),...
        'The contact must be given as an object of ContactFrame class.');
    % compute the spatial position (cartesian position + Euler angles)
    pos = getCartesianPosition(obj, contact);
    rpy = getEulerAngles(obj, contact);
    
    h = tomatrix([pos, rpy]); %effectively as transpose
    % extract the contrained elements
    constr =  contact.WrenchBase' * h;
    % compute the body jacobian 
    jac = getBodyJacobian(obj, contact);
    % extract the contrained elements
    constr_jac = contact.WrenchBase' * jac;
    
    % add as a set of holonomic constraints
    obj = addHolonomicConstraint(obj, contact.Name, constr, constr_jac);
    % the contact wrench input vector
    f = obj.Inputs.(contact.Name);
    
    
    % if the friction coefficients are given, enforce friction cone
    % constraints
    if nargin > 2
        % get the friction cone constraint
        FC = getFrictionCone(obj, f, mu, gamma);
        constr_name = ['friction_cone_', cotnact.Name];
        % add as a set of unilateral constraitns
        obj = addUnilateralConstraint(obj, constr_name, FC, contact.Name);
    end
    
    % if the contact geometry is given, enforce zero moment point
    % constraints
    if nargin > 4
        % get the friction cone constraint
        if nargin > 6
            zmp = getZMPConstraint(obj, f, la, lb, La, Lb);
        else
            zmp = getZMPConstraint(obj, f, la, lb);
        end
        constr_name = ['zmp_', cotnact.Name];
        % add as a set of unilateral constraitns
        obj = addUnilateralConstraint(obj, constr_name, zmp, contact.Name);
        
    end
end
