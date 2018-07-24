function [f_constr, label, auxdata] = getZMPConstraint(obj, f, geometry)
    % returns the symbolic expression of the zero moment point
    % constraints of the contact
    %
    % @note For more detail, please refer to Eq. (28) and Fig. 3 in
    % this article: Grizzle, J. W.; Chevallereau, C.; Sinnet, R. W.
    % & Ames, A. D. Models, feedback control, and open problems of
    % 3D bipedal robotic walking. Automatica, 2014, 50, 1955 - 1988
    %
    % Parameters:
    %  f: the SymVariable of the constraint wrenches
    %  @type SymVariable
    %  geometry: the geometry constant of the contact @type struct
    %
    % Optional fields of geometry:
    %  la: the distance from the origin to the rolling edge along
    %  the negative y-axis  @type double
    %  lb: the distance from the origin to the rolling edge along
    %  the positive y-axis  @type double
    %  La: the distance from the origin to the rolling edge along
    %  the negative x-axis  @type double
    %  Lb: the distance from the origin to the rolling edge along
    %  the positive x-axis  @type double
    %
    % Return values:
    %  f_constr: symbolic expression of the ZMP constraints
    %  @type SymFunction
    %  label: the label of the constraints @type cellstr
    %  auxdata: constant data used in the constraint function
    %  @type cell
    
    assert(size(obj.WrenchBase,2) == length(f),...
        ['The dimension of the constraint wrenchs is incorrect.\n',...
        'Expected %d, instead %d'], size(obj.WrenchBase,2), length(f));
    
    la = SymVariable('gla');
    lb = SymVariable('glb');
    La = SymVariable('gLa');
    Lb = SymVariable('gLb');
    
    fun_name = ['u_zmp_', obj.Name];
    
    switch obj.Type
        case 'PlanarLineContactWithFriction'
            % x, y, z, roll, yaw
            zmp = [la*f(2) - f(3);  % la*fz > mx
                lb*f(2) + f(3)];    % mx > -lb*fz
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                zmp,{f},{[la;lb]});
            
            % create the label text
            label = {'roll_pos';
                'roll_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(geometry.la,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','la');
            validateattributes(geometry.lb,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','lb');
            auxdata = [geometry.la;geometry.lb];
        case 'PointContactWithFriction'
            % x, y, z
            f_constr = []; % no zmp constraints
            label = {};
            auxdata = [];
        case 'PointContactWithoutFriction'
            % z
            f_constr = []; % no zmp constraints
            label = {};
            auxdata = [];
        case 'LineContactWithFriction'
            % x, y, z, roll, yaw
            zmp = [la*f(3) - f(4);  % la*fz > mx
                lb*f(3) + f(4)];    % mx > -lb*fz
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                zmp,{f},{[la;lb]});
            
            % create the label text
            label = {'roll_pos';
                'roll_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(geometry.la,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','la');
            validateattributes(geometry.lb,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','lb');
            auxdata = [geometry.la;geometry.lb];
        case 'LineContactWithoutFriction'
            % z, roll
            zmp = [la*f(1) - f(2);  % la*fz > mx
                lb*f(1) + f(2)];    % mx > -lb*fz
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                zmp,{f},{[la;lb]});
            
            % create the label text
            label = {'roll_pos';
                'roll_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(geometry.la,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','la');
            validateattributes(geometry.lb,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','lb');
            auxdata = [geometry.la;geometry.lb];
        case 'PlanarContactWithFriction'
            % x, y, z, roll, pitch, yaw
            zmp = [la*f(3) - f(4);  % la*fz > mx
                lb*f(3) + f(4);     % mx > -lb*fz
                Lb*f(3) - f(5);     % Lb*fz > my
                La*f(3) + f(5)];    % my > -La*fz
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                zmp,{f},{[la;lb;La;Lb]});
            
            % create the label text
            label = {'roll_pos';
                'roll_neg';
                'pitch_pos';
                'pitch_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(geometry.la,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','la');
            validateattributes(geometry.lb,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','lb');
            validateattributes(geometry.La,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','La');
            validateattributes(geometry.Lb,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','Lb');
            auxdata = [geometry.la;geometry.lb;geometry.La;geometry.Lb];
        case 'PlanarContactWithoutFriction'
            % z, roll, pitch,
            zmp = [la*f(1) - f(2);  % la*fz > mx
                lb*f(1) + f(2);     % mx > -lb*fz
                Lb*f(1) - f(3);     % Lb*fz > my
                La*f(1) + f(3)];    % my > -La*fz
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                zmp,{f},{[la;lb;La;Lb]});
            
            % create the label text
            label = {'roll_pos';
                'roll_neg';
                'pitch_pos';
                'pitch_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(geometry.la,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','la');
            validateattributes(geometry.lb,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','lb');
            validateattributes(geometry.La,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','La');
            validateattributes(geometry.Lb,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','Lb');
            auxdata = [geometry.la;geometry.lb;geometry.La;geometry.Lb];
    end
    
end