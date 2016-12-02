function y = min_jerk(a, t)

[m,n] = size(a);

y = zeros(m,1);
for i = 1:m
    y(i) = a(i,2) + (a(i,1) - a(i,2))*(10*(t/a(i,3))^3 - 15*(t/a(i,3))^4 + 6*(t/a(i,3))^5);
    
end %for


end %function