function [dy_d] = dcwf_time(alpha,t)

[N,M] = size(alpha);

if M == 5
    ECWF = 0;
elseif M == 7
    ECWF = 1;
else
    disp('Error: you have a mishapen A matrix.  Check yourself before you wreak yourself.')
end

dy_d = zeros(N,1);

for i=1:N
    a = alpha(i,:);
    if ECWF == 0
        dy_d(i) = -a(4)*exp(-a(4)*t)*(a(1)*cos(a(2)*t)+a(3)*sin(a(2)*t))+...
            exp(-a(4)*t)*(-a(1)*a(2)*sin(a(2)*t)+a(2)*a(3)*cos(a(2)*t));
    else
        dy_d(i) = -a(4)*exp(-a(4)*t)*(a(1)*cos(a(2)*t)+a(3)*sin(a(2)*t))+...
            exp(-a(4)*t)*(-a(1)*a(2)*sin(a(2)*t)+a(2)*a(3)*cos(a(2)*t))-...
            a(5)*a(6)*sin(a(6)*t)+...
            (2*a(4)*a(5)*a(6)^2/(a(4)^2+a(2)^2-a(6)^2))*cos(a(6)*t);
    end
end

end