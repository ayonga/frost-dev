function [u, extra] = calcControl(obj, vfc, gfc, y_act, y_des)
    % Computes the PD control law for output space directly
    %
    % Parameters:
    % vfc: the vector field f(x) @type colvec
    % gfc: the vector field g(x) @type colvec
    % y_act: the actual outputs @type struct
    % y_des: the desired outputs @type struct
    %
    % Return values:
    % u: the computed torque @type colvec
    % extra: additional computed data @type struct
    %
    % 
    % Required fields of y_act:
    % ya1: the actual velocity (RD1) output @type double
    % Dya1: the first order partial derivatives of ya1 w.r.t
    % to system states @type rowvec
    % ya2: the actual position (RD2) outputs @type colvec
    % Dya2: the first order partial derivatives of ya2 w.r.t
    % to system states @type matrix
    % DLfya2: the second order partial derivatives of ya2 w.r.t
    % to system states @type matrix
    % 
    % Required fields of y_des:
    % yd1: the desired velocity (RD1) output @type double
    % Dyd1: the first order partial derivatives of yd1 w.r.t
    % to system states @type rowvec
    % yd2: the desired position (RD2) outputs @type colvec
    % Dyd2: the first order partial derivatives of yd2 w.r.t
    % to system states @type matrix
    % DLfyd2: the second order partial derivatives of yd2 w.r.t
    % to system states @type matrix


    y1    = y_act.ya1 - y_des.yd1;
    Dy1   = y_act.Dya1 - y_des.Dyd1;


    y2    = y_act.ya2 - y_des.yd2;
    Dy2   = y_act.Dya2 - y_des.Dyd2;
    DLfy2 = y_act.DLfya2 - y_act.DLfyd2;






    if isempty(y1) % no relative degree one output case

        % First Order Lie Derivatives
        Lfy2 = Dy2*vfc;
        % Second Order Lie Derivatives
        LgLfy2 = DLfy2*gfc;

        % decoupling matrix
        A_mat  = LgLfy2;

        % auxilary control input
        mu = - obj.Param.kd * Lfy2 - obj.Param.kp * y2;
    else
        % First Order Lie Derivatives
        Lgy1 = Dy1*gfc;
        Lfy2 = Dy2*vfc;
        % Second Order Lie Derivatives
        LgLfy2 = DLfy2*gfc;
        % decoupling matrix
        A_mat  = [Lgy1; LgLfy2];

        % auxilary control input
        mu = [-(obj.Param.kd/2)*y1;
            - obj.Param.kd * Lfy2 - obj.Param.kp * y2];

    end

    % feedback controller
    u = A_mat \ mu;

    if narargout > 1
        extra = struct;
        extra.mu = mu;
        extra.y1 = y1;
        extra.y2 = y2;        
        extra.Lfy2 = Lfy2;
    end

end