function fcstr = directCollocation(obj, name, x, dx)
    % Return the SymFunction object of the direct collocation constraint
    % given the state (x) and derivatives (dx).
    %
    % Parameters:
    % name: the name suffix of the function @type char
    % x: the state SymVariable @type SymVariable
    % dx: the derivative of states @type SymVariable
    
    
    T  = SymVariable('ts');
    N = SymVariable('nNode');
    numState = length(x);
    
    switch obj.Options.CollocationScheme
        case 'HermiteSimpson'
            
            xn = SymVariable('xn',[numState,1]);
            dxn = SymVariable('dxn',[numState,1]);
            xm = SymVariable('xm',[numState,1]);
            dxm = SymVariable('dxm',[numState,1]);
            
            int_x = [xn - x - (2.*T./(N-1)).*(dxn + 4.*dxm + dx)./6;
                xm - (x+xn)./2 - 2.*T.*(dx-dxn)./(8*(N-1))];
            
            if isnan(obj.Options.ConstantTimeHorizon)
                fcstr = SymFunction(['hs_int_' name],int_x,{T,x,dx,xm,dxm,xn,dxn},{N});
            else
                fcstr = SymFunction(['hs_int_' name],int_x,{x,dx,xm,dxm,xn,dxn},{T,N});
            end
            
            
                
                
        case 'Trapzoidal'
            xn = SymVariable('xn',[numState,1]);
            dxn = SymVariable('dxn',[numState,1]);
            
            int_x = xn - x - (T./(N-1)).*(dxn + dx)./2;
            
            if isnan(obj.Options.ConstantTimeHorizon)
                fcstr = SymFunction(['tr_int_' name],int_x,{T,x,dx,xn,dxn},{N});
            else
                fcstr = SymFunction(['tr_int_' name],int_x,{x,dx,xn,dxn},{T,N});
            end
            
    end

end