classdef IOFeedback_quadprog < Controller
    % This class defines the classic input-output feedback linearization
    % controller
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
    
    
    methods
        
        function obj = IOFeedback_quadprog(name)
            % The controller class constructor function
            %
            % Parameters:
            % name: the controller name @type char
            
            % call superclass constructor
            obj = obj@Controller(name);
            
            
        end
        
        
        
        function [u,u_ff,u_fb] = calcControl(obj, t, x, vfc, gfc, plant, params, logger,alpha,min,max)
            % Computes the classical input-output feedback linearization
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
            global switchCont switchCont2
            global u_prev
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
            % partial derivative of the highest order of derivative (y^n-1) w.r.t.
            % the state variable 'x'
            DLfy = zeros(dim_y,length(x));   % A = DLfy*gfc; Lf = DLfy*vfc;
            ddy = zeros(dim_y,1);
            mu = zeros(dim_y,1);    % The derivatives mu = k(1) y + k(2) y' + ... k(n) y^(n-1)
            idx = 1; % indexing of outputs
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
                
                if y_i.hasPhaseParam
                    if isfield(params,phase_param)
                        p = params.(phase_param);
                    else
                        error('The parameter %s has not been specified in the ''params'' argument.\n', phase_param);
                    end
                else
                    p = [];
                end
                % calculate the desired outputs
                if(t> 18)
                    'lll';
                    
                end

                %%
                y_d{i} = calcDesired(y_i, t, q, dq, a, p);
                % calculate the phase variable
                tau{i} = calcPhaseVariable(y_i, t, q, dq, p);
                s=(t-p(1))/(p(2)-p(1));
                if strcmp(obj.Name,'sit')
                    alpha_virt=reshape(a,3,6);
                else
                    alpha_virt=reshape(a,6,7);
                end
                if s < 0
                    s=0;
                    ds=0;
                    y_d{i}{1}=ExoCalculations.bezier_Jessy(alpha_virt,s);
                    y_d{i}{2}=ExoCalculations.dbezier(alpha_virt,s)*ds;
                    y_d{i}{3}=ExoCalculations.d2bezier(alpha_virt,s).*(ds^2);
                    
                elseif s >1
                    s=1;
                    ds=0;
                    y_d{i}{1}=ExoCalculations.bezier_Jessy(alpha_virt,s);
                    y_d{i}{2}=ExoCalculations.dbezier(alpha_virt,s)*ds;
                    y_d{i}{3}=ExoCalculations.d2bezier(alpha_virt,s).*(ds^2);
                end
                
                % control gain (k0,k1,...kN-1) for the feedback term
                control_param = ['k',y_i.Name];
                if isfield(params,control_param)
                    K = params.(control_param);
                    assert(length(K) == y_i.RelativeDegree,...
                        'The expected length of the control gain parameter ''k'' is: %d\n', y_i.RelativeDegree);
                else
                    if isfield(params, 'epsilon')
                        ep = params.epsilon;
                        K = ones(1, y_i.RelativeDegree);
                        for l= 1:y_i.RelativeDegree
                            K(l) = nchoosek(y_i.RelativeDegree,l-1)*ep^(y_i.RelativeDegree - l + 1);
                        end
                        
                        
                    else
                        error('The control gain %s has not been specified in the ''params'' argument.\n', control_param);
                    end
                    
                    
                end
                
                % stack the partial derivatives of all outputs
                y_indices = idx:idx+y_i.Dimension-1;
                
                if strcmp(y_i.PhaseType, 'TimeBased')
                    DLfy(y_indices,:) = y_a{i}{end};
                    ddy(y_indices) = y_d{i}{end};
                else
                    DLfy(y_indices,:) = y_a{i}{end} - y_d{i}{end};
                end
%                 K=[100,20];
                for j=1:y_i.RelativeDegree
                    mu(y_indices) = mu(y_indices) + K(j)*(y_a{i}{j}-y_d{i}{j});
                end
                % update the starting index for the next output
                idx = idx+y_i.Dimension;
            end
            
            
            
            
            
            % decoupling matrix
            A_mat  = DLfy*gfc;
            % feedforward term
            Lf_mat = DLfy*vfc;
            
            
            % feedforward controller
            if strcmp(y_i.PhaseType, 'TimeBased')
                u_ff = - A_mat \ (Lf_mat - ddy);
            else
                u_ff = - A_mat \ Lf_mat;
            end
            % feedback controller
            u_fb = -A_mat \ mu;
            
            u = u_ff + u_fb;
            %             %%\
            %
            %             fun = @(x)A_mat*x-(Lf_mat-ddy);
            %             ub=[90,192,219,219,180,350,350,180,219,219,192,90];
            %             lb=-ub;
            %             u=lsqnonlin(fun, u_guess,lb,ub);
            %
            %%
            H=diag([1e5 1e5 0.5 5 10 5000 5000 10 5 5 1e5 1e5]);
            H=diag([34 3 2 5 1 8 56 8 1 2 3 34]);
            
            
        
            if strcmp(y_i.PhaseType, 'TimeBased')
                b_sim= Lf_mat - ddy + mu;
            else
                b_sim= Lf_mat + mu;
            end
            A_sim=-A_mat;
            b=zeros(size(b_sim));
            A=zeros(size(A_sim));
            ub=[90,192,219,219,180,350,350,180,219,219,192,90];%maximum value
%              ub=[82,184,124,124,124,198,198,124,124,124,184,82]; 
            
            lb=-ub;
            Aeq=[A_sim];
            beq=[b_sim];

            if isnan(q(9))
                'stop'
            end
            if q(9) <=1.2525
                switchCont=1;
            end
            if q(9) <= 0.1%0.3839  0.2815
                switchCont2=1;
            end
           
            if (strcmp(obj.Name,'stand') && q(9) <= 0.1 ) || switchCont2 || (strcmp(obj.Name,'slowDown') && q(9) <= 0.3839  ) % q(9) <= 1.19
%                  if q(9) >= 0.5
%                 switchCont2=0;
%             end
                s=(q(9)-min{3})/(max{3}-min{3});
                u_opt=ExoCalculations.bezierPoly_stand(alpha{4},s)';
                if s >1
                    u_opt=[   -0.7720
                        -37.8064
                        -57.5509
                        7.2107
                        -0.0070
                        -0.0482
                        -0.0482
                        -0.0070
                        7.2107
                        -57.5509
                        -37.8064
                        0.7720];
                elseif s < 0
                    u_opt=[   -0.7537
                        -31.7742
                        -46.1906
                        -17.6477
                        2.0489
                        0.4582
                        0.5353
                        -9.5352
                        -19.4436
                        -36.1241
                        -10.8183
                        -0.7815];
                end
                
                H=eye(12);
                f=-H*u_opt;
                [u,fval,exitflag]=quadprog(H,f,A,b,Aeq,beq,lb,ub);
            elseif (strcmp(obj.Name,'stand'))% && q(9) <= 1.2525 ) || switchCont
                'pause';
                
%                 s=(t-min{2})/(max{2}-min{2});
                u_opt=ExoCalculations.bezierPoly_stand(alpha{3},s)';
                
                H=eye(12);
                f=-H*u_opt;
                [u,fval,exitflag]=quadprog(H,f,A,b,Aeq,beq,lb,ub)';
                
       
            elseif strcmp(obj.Name,'sit') %|| q(9) > 1.2525
                
%                 s=(t-min{1})/(max{1}-min{1});
                u_opt=ExoCalculations.bezierPoly_stand(alpha{1},s)';
                
                H=eye(12);
                f=-H*u_opt;
%                 u=u_opt;
                [u,fval,exitflag]=quadprog(H,f,A,b,Aeq,beq,lb,ub);
                


            end
            if exitflag==-2
                warning('quadprog failed at time %4.2f with a knee angle of %7.4f', [t,rad2deg(q(9))]);
            end

                if length(u)==0
                  
                    u=u_prev;
                    warning('Length of u is 0: quadprog failed at time %4.2f with a knee angle of %7.4f', [t,rad2deg(q(9))]);
                    
                end
            u_prev=u;
            %             ub=[82,184,124,124,124,198,198,124,124,124,184,82]; %nominal value
            
 %%
            
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
                calc.u_ff = u_ff;
                calc.u_fb = u_fb;
                calc.u = u;
                
                logger.calc = calc;
                
            end
            
        end
    end
    
end