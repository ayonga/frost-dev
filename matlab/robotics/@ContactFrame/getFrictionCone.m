function [f_constr,label,auxdata] = getFrictionCone(obj, f, fric_coef)
    % returns the symbolic expression of the friction cone
    % constraints of the contact
    %
    % @note The friction cone constraints does not includes the
    % ZMP/CWS constraints.
    %
    % Parameters:
    %  f: the SymVariable of the constraint wrenches
    %  @type SymVariable
    %  fric_coef: the coefficient of friction. @type struct
    %
    % Return values:
    %  f_constr: symbolic function of the friction cone
    %  @type SymFunction
    %  label: the label of the constraints @type cellstr
    %  auxdata: constant data used in the constraint function
    %  @type cell
    %
    % Optional fields of fric_coef:
    %  mu: the (static) coefficient of friction. @type double
    %  gamma: the coefficient of torsional friction @type double
    
    assert(size(obj.WrenchBase,2) == length(f),...
        ['The dimension of the constraint wrenchs is incorrect.\n',...
        'Expected %d, instead %d'], size(obj.WrenchBase,2), length(f));
    
    mu = SymVariable('mu');
    gamma = SymVariable('gamma');
    
    
    
    fun_name = ['u_friction_cone_', obj.Name];
    switch obj.Type
        case 'PlanarLineContactWithFriction'
            % x, y, z
            constr = [f(2); % fz >= 0
                f(1) + (mu/sqrt(2))*f(2);
                -f(1) + (mu/sqrt(2))*f(2)];
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                constr,{f},{mu});
            
            % create the label text
            label = {'normal_force';
                'friction_x_pos';
                'friction_x_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(fric_coef.mu,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getFrictionCone','mu');
            auxdata = {fric_coef.mu};
        case 'PlanarPointContactWithFriction'
            % x, y, z
            constr = [f(2); % fz >= 0
                f(1) + (mu/sqrt(2))*f(2);
                -f(1) + (mu/sqrt(2))*f(2)];
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                constr,{f},{mu});
            
            % create the label text
            label = {'normal_force';
                'friction_x_pos';
                'friction_x_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(fric_coef.mu,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getFrictionCone','mu');
            auxdata = {fric_coef.mu};
        case 'PointContactWithFriction'
            % x, y, z
            constr = [f(3); % fz >= 0
                f(1) + (mu/sqrt(2))*f(3);
                -f(1) + (mu/sqrt(2))*f(3);
                f(2) + (mu/sqrt(2))*f(3);
                -f(2) + (mu/sqrt(2))*f(3)];
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                constr,{f},{mu});
            
            % create the label text
            label = {'normal_force';
                'friction_x_pos';
                'friction_x_neg';
                'friction_y_pos';
                'friction_y_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(fric_coef.mu,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getFrictionCone','mu');
            auxdata = {fric_coef.mu};
        case 'PointContactWithoutFriction'
            % z
            constr = f;
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                constr,{f});
            
            % create the label text
            label = {'normal_force';
                };
            auxdata = [];
        case 'LineContactWithFriction'
            % x, y, z, roll, yaw
            constr = [f(3); % fz >= 0
                f(1) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fx
                -f(1) + (mu/sqrt(2))*f(3); % fx < mu/sqrt(2) * fz
                f(2) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fu
                -f(2) + (mu/sqrt(2))*f(3); % fy < mu/sqrt(2) * fz
                f(5) + gamma * f(3);       % -gamma * fz < wy
                -f(5) + gamma * f(3)];     % wy < gamma * fz
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                constr,{f},{[mu;gamma]});
            
            % create the label text
            label = {'normal_force';
                'friction_x_pos';
                'friction_x_neg';
                'friction_y_pos';
                'friction_y_neg';
                'tor_firction_neg';
                'tor_firction_pos';
                };
            
            % validate the provided static friction coefficient
            validateattributes(fric_coef.mu,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getFrictionCone','mu');
            
            % validate the provided torsional friction coefficient
            validateattributes(fric_coef.gamma,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getFrictionCone','gamma');
            auxdata = [fric_coef.mu; fric_coef.gamma];
        case 'LineContactWithoutFriction'
            % z, roll
            constr = f;
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                constr,{f});
            
            % create the label text
            label = {'normal_force';
                };
            auxdata = [];
        case 'PlanarContactWithFriction'
            % x, y, z, roll, pitch, yaw
            constr = [f(3); % fz >= 0
                f(1) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fx
                -f(1) + (mu/sqrt(2))*f(3); % fx < mu/sqrt(2) * fz
                f(2) + (mu/sqrt(2))*f(3);  % -mu/sqrt(2) * fz < fu
                -f(2) + (mu/sqrt(2))*f(3); % fy < mu/sqrt(2) * fz
                f(6) + gamma * f(3);       % -gamma * fz < wz
                -f(6) + gamma * f(3)];     % wz < gamma * fz
            
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                constr,{f},{[mu;gamma]});
            
            % create the label text
            label = {'normal_force';
                'friction_x_pos';
                'friction_x_neg';
                'friction_y_pos';
                'friction_y_neg';
                'tor_firction_neg';
                'tor_firction_pos';
                };
            
            % validate the provided static friction coefficient
            validateattributes(fric_coef.mu,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getFrictionCone','mu');
            
            % validate the provided torsional friction coefficient
            validateattributes(fric_coef.gamma,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getFrictionCone','gamma');
            auxdata = [fric_coef.mu; fric_coef.gamma];
        case 'PlanarContactWithoutFriction'
            % z, roll, pitch,
            constr = f;
            % create a symbolic function object
            f_constr = SymFunction(fun_name,...
                constr,{f});
            
            % create the label text
            label = {'normal_force';
                };
            auxdata = [];
    end
    
    
    
end