classdef IOFeedback_quadprog_lmd < Controller
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
        
        
        
        function [u_lmd] = calcControl(obj, t, x, Je, M, Fv,plant, params, logger,alpha,min,max)
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
            global switchCont
            global u_prev
            eva=0;
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
            %% computing virtual constraints Ayonga's way
            for i=1:ny
                y_i = y(i);
                
                % returns y, y', y'', y^(n-1), Jy^n-1
                
                % calculate the actual outputs
                %         [y_a{i}{:}] = calcActual(y_i,q,dq);
                
                y_a{i} = calcActual(y_i, q, dq);
                
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
                
                
                %%
                y_d{i} = calcDesired(y_i, t, q, dq, a, p);
                % calculate the phase variable
                tau{i} = calcPhaseVariable(y_i, t, q, dq, p);
                
                %% calculating virtual constraints my way
                if(eva)
                    if strcmp(obj.name,'sit')
                        C=[    0.0055   -0.0010   -0.0293
                            0.0858   -0.0267    0.0178
                            -0.0133    0.0024    0.0680
                            0.4433    0.0910    0.0844
                            0.0765   -0.0129   -0.3908
                            -0.1135    0.5597   -0.0413
                            0.0548   -0.0370    0.0289
                            0.2377    0.0982    0.2007
                            -0.1041   -0.2222   -0.3236
                            -0.2757    0.1278    0.4968
                            -0.4670   -0.0715   -0.1621
                            0.1068   -0.5167    0.0440
                            0.1092   -0.5161    0.0348
                            -0.4939   -0.0663   -0.0261
                            0.0613   -0.0923    0.5708
                            0.2232    0.2007   -0.2721
                            -0.2972   -0.0873    0.1004
                            0.0607   -0.0394   -0.0031];
                    else
                        C=[    0.0443    0.1270    0.1222   -0.1164   -0.3795   -0.0467
                            -0.2070   -0.0941    0.1035   -0.0376   -0.0369    0.2094
                            -0.0017   -0.0030    0.0127   -0.0299   -0.0159   -0.0173
                            0.2658   -0.3534    0.0701    0.0529   -0.0897    0.0757
                            -0.0322   -0.0548   -0.3582   -0.4452   -0.4705   -0.0453
                            -0.2623    0.0053   -0.0368    0.1242   -0.0571   -0.1623
                            -0.3317   -0.1265    0.1179   -0.0699   -0.0142    0.2229
                            -0.0613   -0.4945   -0.0606    0.0588    0.3843   -0.2070
                            0.1208    0.4300   -0.0963    0.2058    0.1498    0.6468
                            -0.0257    0.1628    0.4953    0.1794   -0.0534   -0.4234
                            0.0103    0.4202   -0.2018   -0.0393    0.0576   -0.2630
                            0.5211   -0.1025   -0.0280   -0.0711    0.0809    0.0259
                            0.5348   -0.0671    0.0021   -0.0630    0.0113    0.0306
                            0.0042    0.3978   -0.1326    0.0038    0.1882   -0.2817
                            0.1321    0.1034    0.6635   -0.0905    0.0190    0.0904
                            0.0202   -0.0997   -0.2121    0.7794   -0.1696   -0.0318
                            -0.1200    0.0087   -0.0772   -0.2420    0.6056    0.0168
                            -0.3095   -0.0683    0.1312    0.0001   -0.0848    0.2641];
                    end
                    
                    xSym=obj.States.x;
                    dxSym=obj.States.dx;
                    Jh=double(jacobian(C_sit'*xSym,xSym));
                    dJh=double(jacobian(Jh*dxSym,xSym));
                    y_a = C'*q;
                    dy_a = Jh*dq;
                    
                    alpha=params.atrajectorySit;
                    alpha=reshape(alpha,3,6);
                    
                    ds = params.ds;
                    y_d=ExoCalculations.bezier_Jessy(alpha,0);
                    dy_d=ExoCalculations.dbezier(alpha,0).*ds;
                    ddy_d=ExoCalculations.d2bezier(alpha,0).*(ds^2);
                end
                
                %%
                
                
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
                
                kp=K(1);
                kd=K(2);
            end
           if (eva)
               y=y_a-y_d;
               dy=dy_a-dy_d;
           else
               y=y_a{i}{1}-y_d{i}{1};
               dy=y_a{i}{2}-y_d{i}{2};
           end
            
            A=[Je*inv(M)*Be,   Je*inv(M)*Je';Jh*inv(M)*Be, Jh*inv(M)*Je'];
            B=[-Je*inv(M)*Fv-Jedot*dq-Je*inv(M)*Gv_ext;-Jh*inv(M)*Fv-dJh*q+ddy_d-Jh*inv(M)*Gv_ext-kd.*dy-kp.*y];
            
            
      
            
            
           
            if q(9) <=1.2080
                switchCont=1;
            end
            %             if strcmp(obj.Name,'stand') && t>1.04    % q(9) <= 1.19
            
            if (strcmp(obj.Name,'stand') && q(9) <= 1.2080) || switchCont
                'pause';
                s=(q(9)-min{2})/(max{2}-min{2});
                u_opt=ExoCalculations.bezierPoly_stand(alpha{3},s)';
                u_opt_new=[u_opt; zeros(15,1)];
                
                H=[eye(12),zeros(12,15);zeros(15,12),zeros(15,15)];
                f=-H*u_opt_new;
                Aeq=A;
                beq=B;
                [u_lmd,fval,exitflag]=quadprog(H,f,zeros(size(Aeq)),zeros(size(beq)),Aeq,beq,lb,ub);
                
                
                if exitflag==-2
                    'stop'
                    u=u_opt;
                    warning('quadprog failed at time %4.2f with a knee angle of %7.4f', [t,rad2deg(q(9))]);
                    
                end
                %                u=quadprog(H,f,[],[],Aeq,beq);
                
                %             elseif strcmp(obj.Name,'sit') ||  t<=1.04 %q(9) > 1.19
            elseif strcmp(obj.Name,'sit') || q(9) > 1.2080
                
                s=(t-min{1})/(max{1}-min{1});
                u_opt=ExoCalculations.bezierPoly_stand(alpha{1},s)';
                u_opt_new=[u_opt; zeros(15,1)];
                
                H=[eye(12),zeros(12,15);zeros(15,12),zeros(15,15)];
                f=-H*u_opt_new;
                Aeq=A;
                beq=B;
                [u_lmd,fval,exitflag]=quadprog(H,f,zeros(size(Aeq)),zeros(size(beq)),Aeq,beq,lb,ub);
                

                
                if exitflag==-2
                    'stop'
                    u=u_opt;
                    warning('quadprog failed at time %4.2f with a knee angle of %7.4f', [t,rad2deg(q(9))]);
                    
                end
               
            end
            u_prev=u;
            %             ub=[82,184,124,124,124,198,198,124,124,124,184,82]; %nominal value
            
            %%
            %             if size(u,1)==0
            %                 ub=[90,192,219,219,180,350,350,180,219,219,192,90];%maximum value
            %                 lb=-ub;
            %                 u=quadprog(H,f,A,b,Aeq,beq,lb,ub);
            %                 if size(u,1)==0
            % %                     Kt=[0.104;0.104;0.091;0.091;0.091;0.091;0.091;0.091;0.091;0.091;0.104;0.104];
            % %                     r=[136,310,100,100,100,160,160,100,100,100,310,136]';
            % %                     I=[14.4 14.4 30 30 24 30 30 24 30 30 14.4 14.4]';
            % %                     ub=I.*r.*Kt;
            % %                     lb=-ub;
            % %                     u=quadprog(H,f,A,b,Aeq,beq,lb,ub);
            % %                     if size(u,1)==0
            %                         'do something'
            % %                         u=u0;
            % %                     end
            %                 end
            %             end
            
            % if size(u,1)==0
            %     u=u0;
            % end
            % for i=1:12
            %     if u(i) > ub(i)
            %         u(i)=ub(i);
            %     elseif u(i) < lb(i)
            %         u(i)=lb(i);
            %     end
            %
            % end
            
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