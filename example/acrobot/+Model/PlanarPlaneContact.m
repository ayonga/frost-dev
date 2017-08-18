classdef PlanarPlaneContact < ContactFrame
    
    
    methods
        
        function obj = PlanarPlaneContact(varargin)
            
            % consruct the superclass object first
            obj = obj@ContactFrame(varargin{:});
            
            obj.Type = 'CustomPlanarPlaneContact';
            % change the wrench base
            I = eye(6);
            obj.WrenchBase = I(:,[1,3,5]);
        end
    
        function [f_constr,label,auxdata] = getFrictionCone(obj, f, fric_coef)
           
            mu = SymVariable('mu');
            
            % x, y, z
            constr = [f(2); % fz >= 0
                f(1) + (mu/sqrt(2))*f(2);
                -f(1) + (mu/sqrt(2))*f(2)];
            
            % create a symbolic function object
            fun_name = ['u_friction_cone_', obj.Name];
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
            
            
        end
        
        function [f_constr, label, auxdata] = getZMPConstraint(obj, f, geometry)
            
            
            La = SymVariable('gLa');
            Lb = SymVariable('gLb');
            
            % x, y, z, roll, yaw
            zmp = [Lb*f(2) - f(3);  % Lb*fz > my
                La*f(2) + f(3)];    % my > -La*fz
            
            % create a symbolic function object
            fun_name = ['u_zmp_', obj.Name];
            f_constr = SymFunction(fun_name,...
                zmp,{f},{[La;Lb]});
            
            % create the label text
            label = {'pitch_pos';
                'pitch_neg';
                };
            
            % validate the provided static friction coefficient
            validateattributes(geometry.La,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','La');
            validateattributes(geometry.Lb,{'double'},...
                {'scalar','real','>=',0},...
                'ContactFrame.getZMPConstraint','Lb');
            auxdata = [geometry.La;geometry.Lb];
            
            
        end
    end
    
    
end