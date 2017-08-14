classdef truck < ContinuousDynamics
    
    properties
        
        horizon = 1;
        
        speed = 20;
        
        BezierOrder = 5;
    end
    
    
    properties (SetAccess=protected,GetAccess=public)
       
        M
        
        H
        
        L1
        
        E1
    end
    
    methods
        function obj = truck(horizon, speed, BezierOrder)
            % The truck object class construction function
            
            
            
            obj = obj@ContinuousDynamics('FirstOrder', 'LinearTruck');
            
            if nargin > 0
                obj.horizon = horizon;
            end
            
            if nargin > 1
                obj.speed = speed;
            end
            
            if nargin > 2
                obj.BezierOrder = BezierOrder;
            end
            % The state variables:
            % x: forward position
            % vf: forward velocity
            % y: lateral displacement
            % vy: sideslip velocity
            % psi: yaw angle
            % r: raw rate
            % phi: roll angle
            % p: roll rate            
            
            % number of states
            x = SymVariable( {'x','vf','y','vy','psi','r','phi','p'}');
            dx = SymVariable( {'dx','dvf','dy','dvy','dpsi','dr','dphi','dp'}');
            
            obj.addState(x,dx);
            
            obj.setDynamicsEqn();
            
            obj.addRD2Output();
        end
        
        function obj = addRD2Output(obj)
            % The virtual constraints
            
            x = obj.States.x;
            
            ya = x(3) + x(5)*obj.horizon*obj.speed;
            
            tau = x(1)/(obj.horizon*obj.speed);
            
            
            y = VirtualConstraint(obj,ya,'y',...
                'DesiredType','Bezier',...
                'PolyDegree',obj.BezierOrder,...
                'PhaseVariable',tau,...
                'PhaseType','StateBased',...
                'Holonomic',true,...
                'RelativeDegree',2);
            
            obj.addVirtualConstraint(y);
            
        end
        
        function obj = setDynamicsEqn(obj)
            % The first order system dynamics of the simple truck model
            %
            % @note we include the forward velocity as a state variable
            
            % The state variables:
            % x: forward position
            % vf: forward velocity
            % y: lateral displacement
            % vy: sideslip velocity
            % psi: yaw angle
            % r: raw rate
            % phi: roll angle
            % p: roll rate    
            x = obj.States.x;
            
            
            mS=4455;
            IzS=34802.6;
            
            hS=0.1;
            IxS=2283.9;
            Ix=IxS+mS*hS^2;
            IxzS=1626;
            d_springf=0.89;
            d_damperf=1.1;
            
            c_damperf=15e3;
            k_rollf=500*180/pi;
            k_springf=2.5e5;
            d_springr=1;
            d_damperr=1;
            c_damperr=3e4;
            k_rollr=1500*180/pi;
            k_springr=7e5;
            
            k_roll=k_rollf+k_rollr+k_springf*d_springf+k_springr*d_springr;
            c_roll=c_damperf*d_damperf+c_damperr*d_damperr;
            
            
            
            
            g=9.8;
            mUf=570;
            IzUf=335;
            mUr=735;
            IzUr=285;
            aS=1.11;
            l=5;
            bS=l-aS;
            m=mS+mUr+mUf;
            a=(mS*aS+mUr*l)/m;
            b=3.89;
            Iz=IzS+mS*(aS-a)^2+IzUf+mUf*a^2+IzUr+mUr*b^2;
            Fzf=(mUf+mS*bS/l)*g;
            Fzr=(mUr+mS*aS/l)*g;
            
            
            Caf=3.1433e5;
            Car=2.2147e5;
            
            
            obj.M = [1 0 0 0 0 0 0 0;              % x
                0 1 0 0 0 0 0 0;               % vf
                0 0 1 0 0 0 0 0;               % y
                0 0 0 m 0 0 0 mS*hS            % vy
                0 0 0 0 1 0 0 0;               % psi
                0 0 0 0 0 Iz 0 IxzS;           % r
                0 0 0 0 0 0 1 0;               % phi
                0 0 0 mS*hS 0 IxzS 0 Ix];       % p
            
            obj.setMassMatrix(obj.M);
            
            % the state variable: forward velocity
            vf = x(2);
            
            Hs = [0 -1 0 0 0 0 0 0;             % xdot = vf
                0 0 0 0 0 0 0 0;              % constant velocity
                0 0 0 -1 -vf 0 0 0;              % ydot = vy + psi.*vf
                0 0 0 (Caf+Car)./vf 0 m.*vf-(b*Car-a*Caf)./vf 0 0;
                0 0 0 0 0 -1 0 0;
                0 0 0 -(b*Car-a*Caf)./vf 0 (a^2*Caf+b^2*Car)./vf 0 0;
                0 0 0 0 0 0 0 -1;
                0 0 0 0 0 mS*hS.*vf k_roll-mS*g*hS c_roll];
            obj.H = double(subs(Hs,x(2),obj.speed));
            obj.setDriftVector({-Hs*x});
            
            obj.L1 = [0;0;0;Caf;0;a*Caf;0;0];
            u = SymVariable('u');
            obj.addInput('Control','u',u,obj.L1);
            
            obj.E1 = [0;0;0;0;-1;0;0;0];
            rd = SymVariable('rd');
            obj.addInput('External','rd',rd,obj.E1);
            
        end
        
        
        function P1 = pcare(obj,Q,R)
            % return the Riccati matrix P
            
            A = -obj.M^-1 * obj.H;
            B = obj.M^-1 * obj.L1;
            
            [P,~,~]=care(A(3:end,3:end),B(3:end),Q,R,zeros(6,1),eye(6));
            
            P1 = blkdiag(zeros(2),P);
        end
        
        function bounds = boundary_value(obj,x0,rd)
           
            %% boundary values of the NLP variables
            bounds = struct();
            
            % time
            bounds.time.t0.lb = 0;
            bounds.time.t0.ub = 0;
            bounds.time.t0.x0 = 0;
            bounds.time.tf.lb = obj.horizon;
            bounds.time.tf.ub = obj.horizon;
            bounds.time.tf.x0 = obj.horizon;
            %             bounds.time.duration.lb = obj.horizon;
            %             bounds.time.duration.ub = obj.horizon;
            %             bounds.time.duration.x0 = obj.horizon;
            
            % state boundary
            vf = obj.speed;
            x_max = obj.speed*obj.horizon; %
            y_max = 1.5;
            vy_max = 4;
            psi_max = 0.3;
            r_max = 0.3;
            phi_max = 0.3;
            p_max = 0.3;
            umax = 0.3;
            
            
            
            bounds.states.x.lb = [0;vf;-y_max;-vy_max;-psi_max;-r_max;-phi_max;-p_max];
            bounds.states.x.ub = [x_max;vf;y_max;vy_max;psi_max;r_max;phi_max;p_max];
            bounds.states.x.x0 = [0;vf;0.1;0.1;0.0;0;0;0];
            
            % fixed initial condition
            bounds.states.x.initial = x0;
            
            ddx_max = 100; %maximum acceleration
            bounds.states.dx.lb = [vf;-ddx_max;-ddx_max;-ddx_max;-r_max;-ddx_max;-p_max;-ddx_max];
            bounds.states.dx.ub = [vf;ddx_max;ddx_max;ddx_max;r_max;ddx_max;p_max;ddx_max];
            bounds.states.dx.x0 = [vf;0;0;0;0;0;0;0];
            
            bounds.inputs.Control.u.lb = -umax;
            bounds.inputs.Control.u.ub = umax;
            bounds.inputs.Control.u.x0 = 0;
            
            bounds.inputs.External.rd.lb = rd;
            bounds.inputs.External.rd.ub = rd;
            bounds.inputs.External.rd.x0 = rd;
            
            bounds.params.ay.lb = -1000;
            bounds.params.ay.ub = 1000;
            bounds.params.ay.x0 = 0;
            
            
            bounds.kp = 50;
            bounds.kd = 10;
            
            bounds.rd = rd;
        end
        
        
        function x_des = x_des(obj,rd)
            A = -obj.M^-1 * obj.H;
            B = obj.M^-1 * obj.L1;
            AA=[A(3,4) A(3,5) A(3,7) B(3);A(4,4) A(4,5) A(4,7) B(4);A(6,4) A(6,5) A(6,7) B(6);A(8,4) A(8,5) A(8,7) B(8)];
            bb=[-A(3,6)*rd;-A(4,6)*rd;-A(6,6)*rd;-A(8,6)*rd];
            temp=AA^-1*bb;
            x_des=[obj.speed*obj.horizon;
                obj.speed;
                0;
                temp(1);
                temp(2);
                rd;
                temp(3);
                0];
            
            
        end
    end
    
end