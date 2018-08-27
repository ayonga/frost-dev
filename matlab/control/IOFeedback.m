classdef IOFeedback < Controller
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
        
        function obj = IOFeedback(name)
            % The controller class constructor function
            %
            % Parameters:
            % name: the controller name @type char
            
            % call superclass constructor
            obj = obj@Controller(name);
             
            
        end
        
        
        
        function u = calcControl(obj, t, x, vfc, gfc, plant, params, logger)
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
                y_d{i} = calcDesired(y_i, t, q, dq, a, p);
                % calculate the phase variable
                tau{i} = calcPhaseVariable(y_i, t, q, dq, p);
                
                
                
                
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