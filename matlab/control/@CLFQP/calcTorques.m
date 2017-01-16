function [u] = calcTorques(obj, varargin)
    % calculate the control torque inputs
    %
    % Parameters:
    %  varargin: optinal input arguments. In detail
    %   vfc: vector field \f$f(x)$\f
    %   gfc: vector field \f$g(x)$\f
    %   y1: relative degree one output
    %   y2: relative degree two outputs
    %   Dy1: first order Jacobian of y1
    %   Dy2: first order Jacobian of y2
    %   DLfy2: second order Jacobian of y2
    
    
    
    parse(obj.p,varargin{:});
    in = obj.p.Results;
    
    
    
    %% calculate control input
    switch obj.type
        case 'IO'
            ep = obj.options.ep;
            % input-output feedback linearization
            % Calculate relative degree one outputs
            
            if isempty(in.y1) % no relative degree one output case
                % Human-inspired controller
                
                Lfy2 = in.Dy2*in.vfc;
                % Second Lie Derivatives
                LfLfy2 = in.DLfy2*in.vfc;
                LgLfy2 = in.DLfy2*in.gfc;
                
                A_mat  = LgLfy2;
                Lf_mat = LfLfy2;
                mu = -2 * ep * Lfy2 - ep^2 * in.y2;
            else
                % Human-inspired controller
                Lfy1 = in.Dy1*in.vfc;
                Lgy1 = in.Dy1*in.gfc;
                Lfy2 = in.Dy2*in.vfc;
                % Second Lie Derivatives
                LfLfy2 = in.DLfy2*in.vfc;
                LgLfy2 = in.DLfy2*in.gfc;
                
                A_mat  = [Lgy1; LgLfy2];
                Lf_mat = [Lfy1; LfLfy2];
                mu = [-ep*in.y1;
                    -2 * ep * Lfy2 - ep^2 * in.y2];
                
            end
            
            % feedback controller
            u = A_mat \ (- Lf_mat + mu);
            
        case 'PD-Feedback'
            % extract PD gains
            
            % Lfy1 = in.Dy1*in.vfc;
            Lgy1 = in.Dy1*in.gfc;
            % Lfy2 = in.Dy2*in.vfc;
            % Second Lie Derivatives
            % LfLfy2 = in.DLfy2*in.vfc;
            LgLfy2 = in.DLfy2*in.gfc;
            
            A_mat  = [Lgy1; LgLfy2];
            u = A_mat \ (-obj.options.kp.*[0; in.y2] - obj.options.kd.*([y1; in.Lfy2]));
            
            
        case 'QP-CLF'
            if isempty(in.y1) % no relative degree one output case
                % Human-inspired controller
                
                Lfy2 = in.Dy2*in.vfc;
                % Second Lie Derivatives
                LfLfy2 = DLfy2*in.vfc;
                LgLfy2 = DLfy2*in.gfc;
                
                Lf_gammac = LfLfy2;
                etac      = [in.y2;Lfy2];
                Abarc     = LgLfy2;
            else
                % Human-inspired controller
                Lfy1 = in.Dy1*in.vfc;
                Lgy1 = in.Dy1*in.gfc;
                Lfy2 = in.Dy2*in.vfc;
                % Second Lie Derivatives
                LfLfy2 = in.DLfy2*in.vfc;
                LgLfy2 = in.DLfy2*in.gfc;
                
                Lf_gammac = [Lfy1;
                    LfLfy2];
                
                etac = [in.y1;
                    in.y2;
                    Lfy2];
                
                Abarc =[Lgy1;
                    LgLfy2];
                
            end
            
            % QP-CLF
            [u_qp] = calcClfMultiLagrange(obj, controller, model, ...
                etac, Abarc, Lf_gammac, AeqLagrangec,beqLagrangec);
            
            u = u_qp(1:obj.nAct);
            
    end
    
end