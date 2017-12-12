classdef CLFCBFQP < Controller
    % This class defines a class of Control Lyapunov Functions (CLFs) that
    % use quadratic programming (QP)
    %
    % @todo implement the CLF-QP controller
    % 
    % @author ayonga @date 2016-10-14
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        
        
        
    end
    
    methods
        
        function obj = CLFCBFQP(name,flippy,params)
            % The controller class constructor function
            %
            % Parameters:
            % name: the controller name @type char
            
            % call superclass constructor
            obj = obj@Controller(name);

            y = struct2array(flippy.VirtualConstraints);
            ny = length(y);
            
            % total dimension of the virtual constraints
            dim_y = sum([y.Dimension]);
            % total dimension of outputs (including relative degrees)
            dim_eta = sum([y.Dimension.*y.RelativeDegree]);
            
            % some constants required for CLF
            F_mat = zeros(dim_eta);
            G_mat = zeros(dim_eta,dim_y);
            I_mat = eye(dim_eta);
            
            idx = 1;
            etaidx = 1;
            for i=1:ny
                y_i = y(i);
                
                % control gain (k0,k1,...kN-1) for the feedback term
                if isfield(params, 'epsilon')
                    ep = params.epsilon;
                else
                    ep = 1;
                end
                
                
                % stack the partial derivatives of all outputs
                y_indices = idx:idx+y_i.Dimension-1;
                eta_indices = etaidx:etaidx+y_i.Dimension-1;
                
                G_mat(eta_indices+(y_i.RelativeDegree-1)*numel(eta_indices),y_indices) = eye(y_i.Dimension);
                
                if y_i.RelativeDegree > 1 % only modify the first degree outputs (0th derivative). not higher derivatives
                    I_mat(eta_indices,eta_indices) = ep*eye(numel(eta_indices));
                end
                
                for j=1:y_i.RelativeDegree
                    if j < y_i.RelativeDegree
                        F_mat(eta_indices+(j-1)*numel(eta_indices),eta_indices+j*numel(eta_indices)) = eye(numel(eta_indices));
                    end
                end
                % update the starting index for the next output
                idx = idx+y_i.Dimension;
                etaidx = etaidx+y_i.Dimension*y_i.RelativeDegree;
            end
            
            P = care(F_mat,G_mat,eye(dim_eta));

            obj.Param.F_mat = F_mat;
            obj.Param.G_mat = G_mat;
            obj.Param.Pe_mat = I_mat'*P*I_mat;
        end
        
        
        function u = calcControl(obj, t, x, vfc, gfc, plant, params, logger)
            % Computes the control Lyapunov function based control laws
            % control law for virtual constraints
            %
            % Parameters:
            % t: the time instant @type double
            % x: the states @type colvec
            % vfc: the vector field f(x) @type colvec
            % gfc: the vector field g(x) @type colvec
            % plant: the continuous domain @type DynamicalSystem
            % params: the control parameters @type struct
            % logger: the data logger object @type SimLogger
            %
            % Return values:
            % u: the computed torque @type colvec
            
            nx = plant.numState;
            if strcmp(plant.Type,'SecondOrder')
                q = x(1:nx);
                dq = x(nx+1:end);
            else
                q = x;
                dq = []; % will not affect any computation
            end
            
            
            y = struct2array(plant.VirtualConstraints);
            ny = length(y);
            y_a = cell(ny,1);
            y_d = cell(ny,1);
            tau = cell(ny,1);
            
            % total dimension of the virtual constraints
            dim_y = sum([y.Dimension]);
            % total dimension of outputs (including relative degrees)
            dim_eta = sum([y.Dimension.*y.RelativeDegree]);
            % some constants required for CLF
            F_mat = obj.Param.F_mat;
            G_mat = obj.Param.G_mat;
            Pep = obj.Param.Pe_mat;
            % partial derivative of the highest order of derivative (y^n-1) w.r.t.
            % the state variable 'x'
            DLfy = zeros(dim_y,length(x));   % A = DLfy*gfc; Lf = DLfy*vfc;
            ddy = zeros(dim_y,1);
            mu = zeros(dim_y,1);    % The derivatives mu = k(1) y + k(2) y' + ... k(n) y^(n-1)
            eta = zeros(dim_eta,1);
            idx = 1; % indexing of outputs
            etaidx = 1; % indexing of eta
            for i=1:ny
                y_i = y(i);
                
                % returns y, y', y'', y^(n-1), Jy^n-1
                
                % calculate the actual outputs
                %         [y_a{i}{:}] = calcActual(y_i,q,dq);
                offset_param = y_i.OffsetParamName;
                if y_i.hasOffset
                    offset = params.(offset_param);
                    y_a{i} = calcActual(y_i, q, dq, offset);
                else
                    y_a{i} = calcActual(y_i, q, dq);
                end
                % extract the parameter values
               
                output_param = y_i.OutputParamName; % desired output parameters
                phase_param  = y_i.PhaseParamName;  % phase variable parameters
                
                
                if isfield(params,output_param)
                    a = params.(output_param);
                else
                    error('The parameter %s has not been specified in the ''params'' argument.\n', output_param);
                end
                
                if ~isempty(phase_param)
                    if isfield(params,phase_param)
                        p = params.(phase_param);
                    else
                        error('The parameter %s has not been specified in the ''params'' argument.\n', phase_param);
                    end
                else
                    p = [];
                end
                % calculate the desired outputs
                y_d{i} = calcDesired(y_i, t, q, dq, a, p);
                % calculate the phase variable
                tau{i} = calcPhaseVariable(y_i, t, q, dq, p);
                
                
                % control gain (k0,k1,...kN-1) for the feedback term
                if isfield(params, 'epsilon')
                    ep = params.epsilon;
                else
                    ep = 1;
                end
                K = ones(1, y_i.RelativeDegree);
                for l= 1:y_i.RelativeDegree
                    K(l) = nchoosek(y_i.RelativeDegree,l-1)*ep^(y_i.RelativeDegree - l + 1);
                end
                
                % stack the partial derivatives of all outputs
                y_indices = idx:idx+y_i.Dimension-1;
                eta_indices = etaidx:etaidx+y_i.Dimension-1;
                                
                if strcmp(y_i.PhaseType, 'TimeBased')
                    DLfy(y_indices,:) = y_a{i}{end};
                    ddy(y_indices) = y_d{i}{end};
                else
                    DLfy(y_indices,:) = y_a{i}{end} - y_d{i}{end};
                end
                for j=1:y_i.RelativeDegree
                    mu(y_indices) = mu(y_indices) + K(j)*(y_a{i}{j}-y_d{i}{j});
                    eta(eta_indices+(j-1)*numel(eta_indices)) = y_a{i}{j} - y_d{i}{j};
                end
                % update the starting index for the next output
                idx = idx+y_i.Dimension;
                etaidx = etaidx+y_i.Dimension*y_i.RelativeDegree;
            end
            
            
            %% here is where the CLF based controller is designed 
            % decoupling matrix
            A_mat  = DLfy*gfc;
            % feedforward term
            Lf_mat = DLfy*vfc;
            
            % Lyapunov function
            Veta = eta' * Pep * eta;
            
            % CLF V for u
            LgVetau = 2*eta'*Pep*G_mat*A_mat;
            LfVetau = eta'*(F_mat'*Pep+Pep*F_mat)*eta+0.3660*ep*Veta+2*eta'*Pep*G_mat*Lf_mat-2*eta'*Pep*G_mat*ddy;
            
            Hmat = A_mat' * A_mat;
            Hmatappend = blkdiag(1,Hmat,eye(3));
%             Q = blkdiag(Hmatappend,eye(2));

            
            % feedforward controller
            if strcmp(y_i.PhaseType, 'TimeBased')
%                 fvec = Lf_mat'*A_mat - ddy'*A_mat;
                fvecappend = [0, Lf_mat'*A_mat - ddy'*A_mat,0,0,0];
            else
%                 fvec = Lf_mat'*A_mat;
                fvecappend = [0, Lf_mat'*A_mat,0,0,0];
            end

            A_cons = [-1, LgVetau, 0, 0, 0];
            b_cons =  -LfVetau;
            
            %% friction forcing constraints
            normal_vector = normal_vector_LR(q)';
            tangent_vector_x = tangent_vector_x_LR(q)';
            tangent_vector_y = tangent_vector_y_LR(q)';
            Lfaccel = [DLf_barrier_x(q,dq);
                        DLf_barrier_y(q,dq);
                        DLf_barrier_z(q,dq)]*vfc+[0;0;9.81];
                
            Lgaccel = [DLf_barrier_x(q,dq);
                        DLf_barrier_y(q,dq);
                        DLf_barrier_z(q,dq)]*gfc;
            
            normal_Lf_accel = normal_vector*Lfaccel;
            normal_Lg_accel = normal_vector*Lgaccel;
            
            tangent_Lfxaccel = tangent_vector_x*Lfaccel;
            tangent_Lgxaccel = tangent_vector_x*Lgaccel;
            
            tangent_Lfyaccel = tangent_vector_y*Lfaccel;
            tangent_Lgyaccel = tangent_vector_y*Lgaccel;
            
            Lgfriction_upper = - 0.36*[normal_Lg_accel;
                                       normal_Lg_accel] + [tangent_Lgxaccel;
                                                                   tangent_Lgyaccel];
            Lgfriction_lower = - 0.36*[normal_Lg_accel;
                                       normal_Lg_accel] - [tangent_Lgxaccel;
                                                                   tangent_Lgyaccel];


            Lffriction_upper =   0.36*[normal_Lf_accel;
                                       normal_Lf_accel] - [tangent_Lfxaccel;
                                                                   tangent_Lfyaccel];
            Lffriction_lower =   0.36*[normal_Lf_accel;
                                       normal_Lf_accel] + [tangent_Lfxaccel;
                                                                   tangent_Lfyaccel];
            
            A_cons = [A_cons;
                      0, - normal_Lg_accel, 0,0,0;
%                       zeros(2,1), Lgfriction_upper, zeros(2,3);
%                       zeros(2,1), Lgfriction_lower, zeros(2,3)
                      ];
                  
            b_cons = [b_cons;
                      normal_Lf_accel;
%                       Lffriction_upper;
%                       Lffriction_lower
                      ];
                                                               
                  
            %% This is the formula for the hyperplane constraints
            point_1 = [-0.0,0.4 ,0];
            point_2 = [0.2,0.4 ,0];
            direction_x1 = [-1,0,0];
            direction_x2 = [1,0,0];
            direction_y = [0,-1,0];
            
            point_endeff = [endeffx_sca_LR(q),endeffy_sca_LR(q),endeffz_sca_LR(q)];
            x1_constr = (point_endeff - point_1)*direction_x1'; % positive value means safe
            x2_constr = (point_endeff - point_2)*direction_x2'; % positive value means safe
            y_constr = (point_endeff - point_1)*direction_y'; % positive value means safe
            
            %% This is the formula for CBF constraints -- please note
            % eta_bdot = F_b eta_b + G_b mu_b
            % mu_b = - K_p eta_b => eta_bdot = (F_b - G_b K_p) eta_b - this
            % system must be stable
            % nth derivative is when the control input is supposed to appear
            % therefore the constraint is
            % B^(nth derivative) => L_fB + L_gB u >= mu_b or -L_fB - L_gB*u
            % <= -mu_b or -L_gB*u <= L_fB + K_p*eta_b
            epsilon = 5;
            K_b = [epsilon^2 2*epsilon];
            
            eta_x_b = [point_1(1);0] - eta_barrier_x(x(1:6),x(7:12));
            mu_x_b = -K_b*eta_x_b;
            eta_x2_b =  eta_barrier_x(x(1:6),x(7:12)) - [point_2(1);0];
            mu_x2_b = -K_b*eta_x2_b;
            
            eta_y_b = [point_1(2);0] - eta_barrier_y(x(1:6),x(7:12));
            mu_y_b = -K_b*eta_y_b;
            
            DLf_x_barrier = -DLf_barrier_x(x(1:6),x(7:12));
            DLf_x2_barrier = DLf_barrier_x(x(1:6),x(7:12));
            DLf_y_barrier = -DLf_barrier_y(x(1:6),x(7:12));
            LfB_x = DLf_x_barrier*vfc;
            LgB_x = DLf_x_barrier*gfc;
            LfB_x2 = DLf_x2_barrier*vfc;
            LgB_x2 = DLf_x2_barrier*gfc;
            LfB_y = DLf_y_barrier*vfc;
            LgB_y = DLf_y_barrier*gfc;
            
            A_cons = [A_cons;
                  0, -LgB_x,  -1000, 0, 0;
                  0, -LgB_x2,   0, -1000, 0;
                  0, -LgB_y,      0, 0, -1000;
                  zeros(1,7),     1, 1, 1;
                  zeros(1,7), -1000, 0, 0;
                  zeros(1,7), 0,-1000,0;
                  zeros(1,7), 0,0,-1000];
            
            b_cons = [b_cons;
                  LfB_x - mu_x_b;
                  LfB_x2 - mu_x2_b;
                  LfB_y - mu_y_b;
                  2;
                  x1_constr;
                  x2_constr;
                  y_constr];

            %% gurobi optimization
            names = {'delta','u1','u2','u3','u4','u5','u6','w1','w2','w3'};
            model.varnames = names;
            model.lb = -Inf*ones(size(names));
            model.ub =  Inf*ones(size(names));
            model.Q = sparse(Hmatappend);
            model.A = sparse(A_cons);
            model.obj = 2*fvecappend;
            model.rhs = b_cons;
            model.vtype = 'CCCCCCCBBB';
            model.sense = repmat('<',1,numel(b_cons));
            dialogoutpt.outputflag = 0;
            
%             gurobi_write(model, 'qp.lp');
            
            results = gurobi(model,dialogoutpt);
%             if strcmp(results.status,'OPTIMAL')
                u = results.x(2:end-3);
                int_vars = results.x(end-2:end);
%             else
%                 u = zeros(6,1);
%                 int_vars = zeros(3,1);
%             end
            
            %% mosek optimization
%             a = A;
%             blc = [];
%             buc = b;
%             
%             integer_indices = [8, 9];
% %             integer_indices = [];
%             [res] = mskmiqpopt(q,c,a,blc,buc,[],[],integer_indices,[],'minimize echo(0)'); % echo (0) forces no output
% %             u = res.sol.itr.xx(2:end-2);
%             u = res.sol.int.xx(2:end-2);
            
            %% the whole quadratic program RUNS here, understand???? you better understand
%             options = optimoptions('quadprog','Algorithm','interior-point-convex','display','off');
%             
% %             result = quadprog(Hmat,bmat,LgVetau,-LfVetau,[],[],[],[],[],options);
%            result = quadprog(Hmatappend,fvecappend,A_cons,b_cons,[],[],[],[],[],options);
%            
%            u = result(2:end-2);

            %% loggind data stuff
            if ~isempty(logger)
                calc = logger.calc;
                
                calc.mu = mu;
                
                for i=1:ny
                    y_i = y(i);
                    output_name = y_i.Name;
                    
                    for j=1:y_i.RelativeDegree
                        
                        if j > 1
                            ya_name = ['d' num2str(j-1) 'ya_' output_name];
                            yd_name = ['d' num2str(j-1) 'yd_' output_name];
                            tau_name = ['d' num2str(j-1) 'tau_' output_name];
                        else
                            ya_name = ['ya_' output_name];
                            yd_name = ['yd_' output_name];
                            tau_name = ['tau_' output_name];
                        end
                        calc.(ya_name) = y_a{i}{j};
                        calc.(yd_name) = y_d{i}{j};
                        calc.(tau_name) = tau{i}{j};
                        
                    end
                
                end
                calc.u = u;
                calc.int_var = int_vars;

                logger.calc = calc;
            end
            
        end
    end
    
end