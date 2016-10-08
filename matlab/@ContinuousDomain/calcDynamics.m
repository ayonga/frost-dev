function [dx, u, Fe] = calcDynamics(obj, t, x, model, ref)
        % This function computes the continuousd dynamics of the dynmical
        % system.
        %
        % Parameters:
        %  t: the time instant @type double
        %  x: the system states @type colvec
        % Return values:
        %  dx: the first order derivatives @type colvec
        %
        
        
        % Extract states to angles and velocities
        qe  = x(model.qeIndices);
        dqe = x(model.dqeIndices);
        
        % compute naturual dynamics
        [De, He] = calcNaturalDynamics(model,x);
        
        
        % Calculate holonomic constraints jacobians
        Je    = obj.holConstrJac(x);
        Jedot = obj.holConstrJacDot(x);
        Be    = obj.actuatorMap(x);
        
        XiInv = Je * (De \ transpose(Je));
        
        % compute vector fields
        % f(x)
        vfc = [
            dqe;
            De \ ((transpose(Je) * (XiInv \ (transpose(transpose(De) \ transpose(Je)))) -...
            Ie) * He - transpose(Je) * (XiInv \ Jedot * dqe))];
        
        
        % g(x)
        gfc = [
            zeros(size(Be));
            De \ (Ie - transpose(Je)* (XiInv \ (transpose(transpose(De) \ transpose(Je))))) * Be];
        
        % check the validity of the holonomic constraints
        tol = 1e-3;
        dhe = Je * dqe;
        do_warn = true;
        if do_warn && norm(dhe) > tol
            warning('holonomic constraint violated');
            keyboard;
        end
        
        % compute outputs
        [y_a1, y_a2, Dy_a1, Dy_a2, DLfy_a2] = calcActualOutputs(obj, x, model);
        [y_d1, y_d2, Dy_d1, Dy_d2, DLfy_d2, tau, dtau] = ...
            calcDesiredOutputs(obj, t, x, model, controller);
        
        y1    = y_a1 - y_d1;
        y2    = y_a2 - y_d2;
        Dy1   = Dy_a1 - Dy_d1;
        Dy2   = Dy_a2 - Dy_d2;        
        DLfy2 = DLfy_a2 - DLfy_d2;
        
        
        % compute control input
        u = calcTorques(obj.controller, vfc, gfc, y1, y2, Dy1, Dy2, DLfy2);
        
        % Calculate the dynamics
        dx = vfc + gfc * u;
        % Calculate constrained forces
        Fe = -XiInv \ (Jedot * dqe + Je * (De \ (Be * u - He)));
        
        % log data
        if nargin > 4
            calc.t = t;
            calc.x = x;
            
            
            calc.qe   = qe;
            calc.dqe  = dqe;
            calc.ddqe = dx(model.dqeIndices);
            calc.u    = u;
            calc.uq   = Be * u;
            calc.Fe   = Fe;
            calc.hd   = obj.holConstrFunc(x);
            calc.tau  = tau;
            calc.dtau = dtau;
            
            ref.calc = calc;
        end
        
    end