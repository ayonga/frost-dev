function ret = BertSchneiderFormula(p1,p2,p3,p4,diagonal1_sq,diagonal2_sq)
%
%
%   between two lines p1_p2 and p3_p4. Calculates the following formula
% % % 
% % % 
% % % 
a = tovector(p1 - p3);
b = tovector(p3 - p2);
c = tovector(p2 - p4);
d = tovector(p4 - p1);

areaoftriangle1 = norm(cross(a,d))/2;
areaoftriangle2 = norm(cross(b,c))/2;

total = areaoftriangle1(1) + areaoftriangle2(1);
areasq = total.^2;

d2sq = (16*areasq - ( norm(b).^2 + norm(d).^2 - norm(a).^2 - norm(c).^2 ).^2) / 4 / diagonal1_sq;



% areasq = 4 .* diagonal1.^2 .* diagonal2.^2 - (sum(b.^2) + sum(d.^2) - sum(a.^2) - sum(c.^2)).^2 ;


ret = d2sq(1) -  diagonal2_sq;

end

function ret = cross(a,b)
    ret = [a(2).*b(3) - a(3).*b(2),a(3).*b(1)-a(1).*b(3),a(1).*b(2)-a(2).*b(1)];
end