function [y_d] = cwf_time(alpha,t)

[N,M] = size(alpha);

if M == 5
    ECWF = 0;
elseif M == 7
    ECWF = 1;
else
    disp('Error: you have a mishapen A matrix.  Check yourself before you wreak yourself.')
end

y_d = zeros(N,1);

for i=1:N
    a = alpha(i,:);
    if ECWF == 0
        y_d(i) = exp(-a(4)*t)*(a(1)*cos(a(2)*t)+a(3)*sin(a(2)*t))+a(5);
    else
        y_d(i) = exp(-a(4).*t).*(a(1).*cos(a(2).*t)+a(3).*sin(a(2).*t))+...
            a(5).*cos(a(6).*t)+...
            (2.*a(4).*a(5).*a(6)./(a(4).^2+a(2).^2-a(6).^2)).*sin(a(6).*t)+a(7);
    end
   
end

end