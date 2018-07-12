function fcstr = directCollocation(obj, name, x, dx)
    % Return the SymFunction object of the direct collocation constraint
    % given the state (x) and derivatives (dx).
    %
    % Parameters:
    % name: the name suffix of the function @type char
    % x: the state SymVariable @type SymVariable
    % dx: the derivative of states @type SymVariable
    
    
    T  = [SymVariable('t0');SymVariable('tf')];
    Ts = T(2) - T(1);
    N = SymVariable('nNode');
    numState = length(x);
    nNode = obj.NumNode;
    switch obj.Options.CollocationScheme
        case 'HermiteSimpson'
            
            xn = SymVariable('xn',[numState,1]);
            dxn = SymVariable('dxn',[numState,1]);
            xm = SymVariable('xm',[numState,1]);
            dxm = SymVariable('dxm',[numState,1]);
            
            int_x = [xn - x - (2.*Ts./(N-1)).*(dxn + 4.*dxm + dx)./6;
                xm - (x+xn)./2 - 2.*Ts.*(dx-dxn)./(8*(N-1))];
            
            if isnan(obj.Options.ConstantTimeHorizon)
                fcstr = SymFunction(['hs_int_' name],int_x,{T,x,dx,xm,dxm,xn,dxn},{N});
            else
                fcstr = SymFunction(['hs_int_' name],int_x,{x,dx,xm,dxm,xn,dxn},{T,N});
            end
            
            
                
                
        case 'Trapezoidal'
            xn = SymVariable('xn',[numState,1]);
            dxn = SymVariable('dxn',[numState,1]);
            
            int_x = xn - x - (Ts./(N-1)).*(dxn + dx)./2;
            
            if isnan(obj.Options.ConstantTimeHorizon)
                fcstr = SymFunction(['tr_int_' name],int_x,{T,x,dx,xn,dxn},{N});
            else
                fcstr = SymFunction(['tr_int_' name],int_x,{x,dx,xn,dxn},{T,N});
            end
            
        case 'PseudoSpectral'
            t = sym('t');
            p = legendreP(nNode-1,t);
            dp = jacobian(p,t);
            
            roots = vpasolve(dp*(1-t)*(1+t)==0);
            
            D_LGL = zeros(nNode);
            for i=1:nNode
                for j=1:nNode
                    if i==j
                        if j== 1
                            D_LGL(i,j) = - (nNode-1)*(nNode)/4;
                        elseif j==nNode
                            D_LGL(i,j) = (nNode-1)*(nNode)/4;
                        else
                            D_LGL(i,j) = 0;
                        end
                    else
                        D_LGL(i,j) = subs(p,t,roots(i))/(subs(p,t,roots(j))*(roots(i) - roots(j)));
                    end
                end
            end
            
            KD_LGL = kron(D_LGL, eye(numState));
            
            xn = cell(1,nNode);
            dxn = cell(1,nNode);
            
            for i=1:nNode
                xn{i} = SymVariable(['x',num2str(i)],[numState,1]);
                dxn{i} = SymVariable(['dx',num2str(i)],[numState,1]);
            end
            
            X = transpose(flatten([xn{:}]));
            dX = transpose(flatten([dxn{:}]));
            int_x = dX.*(Ts./2) - KD_LGL*X;
            
            dep = [xn;dxn];
            if isnan(obj.Options.ConstantTimeHorizon)
                fcstr = SymFunction(['ps_int_' name '_' obj.Name],int_x,[{T},dep(:)']);
            else
                fcstr = SymFunction(['ps_int_' name '_' obj.Name],int_x,dep(:)',{T});
            end
    end

end