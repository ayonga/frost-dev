function ret = outputRD2Constraints(obj,options,ddx)
    % This function will return the symbolic expression (SymFunction) of
    % the output dynamical equation constraints for virtual constraints
    %    
    %
    % Return values:
    %  ret: a list of symbolic function objects @type varargout
    
    
    t = SymVariable('t');
    x = obj.States.x;
    dx = obj.States.dx;
    if isa(obj,'FirstOrderSystem')
        if nargin ~= 3
            error('The (ddx) symbolic representation must be provided for the first order system');
        end       
    else
        ddx = obj.States.ddx;
    end
    
    
    
    if ~isfield(obj.TrajOptFuncs,'RD2Outputs')
        
        
        Kd = SymVariable('kd');
        Kp = SymVariable('kp');
        a = obj.Params.a;
        
        ya2 = obj.RD2Output.Act;
        J_ya2 = jacobian(ya2,x);
        dya2 = J_ya2*dx;
        Jdot_ya2 = jacobian(dya2,x);
        ddya2 = J_ya2*ddx + Jdot_ya2*dx;
        
        
        
        if strcmp(obj.RD2Output.Type,'StateBased')
            yd2 = tomatrix(subs(obj.RD2Output.Des,t,obj.RD2Output.PhaseVar));
            J_yd2 = jacobian(yd2,x);
            dyd2 = J_yd2*dx;
            Jdot_yd2 = jacobian(dyd2,x);
            ddyd2 = J_yd2*ddx + Jdot_yd2*dx;
            
            y2 = SymFunction(['y2_' obj.Name],ya2-yd2,{x,a});
            dy2 = SymFunction(['dy2_' obj.Name],dya2-dyd2,{x,dx,a});
            ddy2 = SymFunction(['ddy2_' obj.Name],ddya2-ddyd2 + Kd*(dya2-dyd2) + Kp*(ya2-yd2),{x,dx,a},{Kd,Kp});
            
        elseif strcmp(obj.RD2Output.Type,'TimeBased')
            %|@todo replace time variable with the actual time using the
            %distribution
            
            yd2 = obj.RD2Output.Des;
            dyd2 = jacobian(yd2,flatten(t));
            ddyd2 = jacobian(dyd2,flatten(t));
            
            k = SymVariable('k');
            T  = SymVariable('ts');
            nNode = SymVariable('nNode');
            tsubs = ((k-1)/(nNode-1))*T;
            
            yd_s = subs(yd2,t,tsubs);
            dyd_s = subs(dyd2,t,tsubs);
            ddyd_s = subs(ddyd2,t,tsubs);
            
            if ~isnan(options.ConstantTimeHorizon)
                y2 = SymFunction(['y2_' obj.Name],ya2-yd_s,{x,a},{T,k,nNode});
                dy2 = SymFunction(['dy2_' obj.Name],dya2-dyd_s,{x,dx,a},{T,k,nNode});
                ddy2 = SymFunction(['ddy2_' obj.Name],ddya2-ddyd_s + Kd*(dya2-dyd_s) + Kp*(ya2-yd_s),{x,dx,a},{Kd,Kp,T,k,nNode});
            else
                y2 = SymFunction(['y2_' obj.Name],ya2-yd_s,{T,x,a},{k,nNode});
                dy2 = SymFunction(['dy2_' obj.Name],dya2-dyd_s,{T,x,dx,a},{k,nNode});
                ddy2 = SymFunction(['ddy2_' obj.Name],ddya2-ddyd_s + Kd*(dya2-dyd_s) + Kp*(ya2-yd_s),{T,x,dx,a},{Kd,Kp,k,nNode});
            end
            
        end
        obj.TrajOptFuncs.RD2Outputs.('y2') = y2;
        obj.TrajOptFuncs.RD2Outputs.('dy2') = dy2;
        obj.TrajOptFuncs.RD2Outputs.('ddy2') = ddy2;
    end
    ret = obj.TrajOptFuncs.RD2Outputs;
end