function [expr, n_param] = getDesOutputExpr(type)
    % Returns the symbolic expression of desired velocity output
    % based on the function type
    %
    % Parameters:
    % type: the desired output function type @type char

    switch type
        case 'Constant'
            expr = '{a[1]}';
            n_param = 1;
        case 'MinJerk'
            expr = '{a[2]+(a[1]-a[2])*(10*(t/a[3])^3-15*(t/a[3])^4+6*(t/a[3])^5)}';
            n_param = 3;
        case 'Bezier4thOrder'
            expr = '{Sum[a[j+1]*Binomial[4,j]*t^j*(1-t)^(4-j),{j,0,4}]}';
            n_param = 5;
        case 'Bezier5thOrder'
            expr = '{Sum[a[j+1]*Binomial[5,j]*t^j*(1-t)^(5-j),{j,0,5}]}';
            n_param = 6;
        case 'Bezier6thOrder'
            expr = '{Sum[a[j+1]*Binomial[6,j]*t^j*(1-t)^(6-j),{j,0,6}]}';
            n_param = 7;
        case 'CWF'
            expr = '{(a[1] Cos[a[2] t]+a[3] Sin[a[2] t])/Exp[a[4]t]+a[5]}';
            n_param = 5;
        case 'ECWF'
            expr = ['(a[1] Cos[a[2] t]+a[3] Sin[a[2] t])/Exp[a[4]t]+',...
                '(2*a[4]*a[5]*a[6])/(a[4]^2+a[2]^2-a[6]^2) Sin[a[6]*t]+a[7]}'];
            n_param = 7;
        otherwise
            error('Undefined function type for the desired velocity output.');

    end
end