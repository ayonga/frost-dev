function fx = collocationConstraints(obj, options)
    % This function will return the symbolic expression (SymFunction) of
    % the direct collocation constraints for the dynamical system object.
    %
    % Parameters:
    %  options: the options @type struct
    %
    % Return values:
    %  varargout: a list of symbolic function objects @type varargout
    
    
    switch options.CollocationScheme
        case 'HermiteSimpson'
            
            x = obj.States.x;
            dx = obj.States.dx;
            T  = SymVariable('ts');
            N = SymVariable('nNode');
            xn = SymVariable('xn',[obj.numState,1]);
            dxn = SymVariable('dxn',[obj.numState,1]);
            xm = SymVariable('xm',[obj.numState,1]);
            dxm = SymVariable('dxm',[obj.numState,1]);
            
            %% the interior node slope: delta = 0
            if ~isfield(obj.TrajOptFuncs.Collocation, 'hs_int_x')
                
                int_x = [xn - x - (T./(N-1)).*(dxn + 4.*dxm + dx)./6;
                    xm - (x+xn)./2 - T.*(dx-dxn)./(8*(N-1))];
                if isnan(options.ConstantTimeHorizon)
                    hs_int_x = SymFunction(['hs_int_x_' obj.Name],int_x,{T,x,dx,xm,dxm,xn,dxn},{N});
                else
                    hs_int_x = SymFunction(['hs_int_x_' obj.Name],int_x,{x,dx,xm,dxm,xn,dxn},{T,N});
                end
                obj.TrajOptFuncs.Collocation.hs_int_x = hs_int_x;
                
            end
            
            
            
            %% for second-order system, we also need to integrate dx
            if isa(obj,'SecondOrderSystem')
                ddx = obj.States.ddx;
                ddxn = SymVariable('ddxn',[obj.numState,1]);
                ddxm = SymVariable('ddxm',[obj.numState,1]);
                %% the interior node slope: delta = 0
                if ~isfield(obj.TrajOptFuncs.Collocation, 'hs_int_dx')
                    
                    int_dx = [dxn - dx - (T./(N-1)).*(ddxn + 4.*ddxm + ddx)./6;
                        dxm - (dx+dxn)./2 - T.*(ddx-ddxn)./(8*(N-1))];
                    if isnan(options.ConstantTimeHorizon)
                        hs_int_dx = SymFunction(['hs_int_dx_' obj.Name],int_dx,{T,dx,ddx,dxm,ddxm,dxn,ddxn},{N});
                    else
                        hs_int_dx = SymFunction(['hs_int_dx_' obj.Name],int_dx,{dx,ddx,dxm,ddxm,dxn,ddxn},{T,N});
                    end
                    obj.TrajOptFuncs.Collocation.hs_int_dx = hs_int_dx;
                end
                
                
               
            end
            
            fx = obj.TrajOptFuncs.Collocation;
        case 'Trapzoidal'
            
            
        case 'PseudoSpectral'
            
            
    end
end