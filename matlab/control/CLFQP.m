classdef CLFQP < Controller
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
        
        function obj = CLFQP(name)
            % The controller class constructor function
            %
            % Parameters:
            % name: the controller name @type char
            
            % call superclass constructor
            obj = obj@Controller(name);
            warning('P matrix from the Ricatti equation not verified for relative degree one outputs and not efficiently computed');
%             error('This class has not been completely defined yet.');
            
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
            F_mat = zeros(dim_eta);
            G_mat = zeros(dim_eta,dim_y);
            I_mat = eye(dim_eta);
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
                    K = ones(1, y_i.RelativeDegree);
                    for l= 1:y_i.RelativeDegree
                        K(l) = nchoosek(y_i.RelativeDegree,l-1)*ep^(y_i.RelativeDegree - l + 1);
                    end
                    
                    
                else
                    error('The control gain %s has not been specified in the ''params'' argument.\n', control_param);
                end
                
                
                % stack the partial derivatives of all outputs
                y_indices = idx:idx+y_i.Dimension-1;
                eta_indices = etaidx:etaidx+y_i.Dimension-1;
                
                G_mat(eta_indices+(y_i.RelativeDegree-1)*numel(eta_indices),y_indices) = eye(y_i.Dimension);
                
                if y_i.RelativeDegree > 1 % only modify the first degree outputs (0th derivative). not higher derivatives
                    I_mat(eta_indices,eta_indices) = ep*eye(numel(eta_indices));
                end
                
                if strcmp(y_i.PhaseType, 'TimeBased')
                    DLfy(y_indices,:) = y_a{i}{end};
                    ddy(y_indices) = y_d{i}{end};
                else
                    DLfy(y_indices,:) = y_a{i}{end} - y_d{i}{end};
                end
                for j=1:y_i.RelativeDegree
                    mu(y_indices) = mu(y_indices) + K(j)*(y_a{i}{j}-y_d{i}{j});
                    eta(eta_indices+(j-1)*numel(eta_indices)) = y_a{i}{j} - y_d{i}{j};
                    
                    if j < y_i.RelativeDegree
                        F_mat(eta_indices+(j-1)*numel(eta_indices),eta_indices+j*numel(eta_indices)) = eye(numel(eta_indices));
                    end
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
            P = care(F_mat,G_mat,eye(dim_eta));
            Pep = I_mat' * P * I_mat;
            Veta = eta' * Pep * eta;
            
%             % CLF V for mu
%             LgVetamu = 2*eta'*Pep*G_mat;
%             LfVetamu = eta'*(F_mat'*Pep + Pep*F_mat)*eta + 0.3660*ep*Veta; 
            
            % CLF V for u
            LgVetau = 2*eta'*Pep*G_mat*A_mat;
            LfVetau = eta'*(F_mat'*Pep+Pep*F_mat)*eta+0.3660*ep*Veta+2*eta'*Pep*G_mat*Lf_mat-2*eta'*Pep*G_mat*ddy;
            
            Hmat = A_mat' * A_mat;
            
            % feedforward controller
            if strcmp(y_i.PhaseType, 'TimeBased')
                bmat = Lf_mat'*A_mat - ddy'*A_mat;
%                 u_ff = - A_mat \ (Lf_mat - ddy);
            else
                bmat = Lf_mat'*A_mat;
%                 u_ff = - A_mat \ Lf_mat;
            end
            
            options = optimoptions('quadprog','Algorithm','interior-point-convex','display','off');
            
%             muqp = quadprog(eye(6),[],LgVetamu,-LfVetamu,[],[],[],[],[],options);
%             disp(max(mu - muqp))
%             mu = muqp;
%             u_fb = A_mat \ mu;
%             u = u_ff + u_fb;
            
            u = quadprog(Hmat,bmat,LgVetau,-LfVetau,[],[],[],[],[],options);
%             disp(max(u - uqp))
            % feedback controller

            
            
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
%                 calc.u_ff = u_ff;
%                 calc.u_fb = u_fb;
                calc.u = u;

                logger.calc = calc;
            end
            
        end
    end
    
end