function fcn = bezier(coeff,s) %accepts S in row or column and returns an array of the same orientation
  
[n,m] = size(coeff);
[x,y] = size(s);

m=m-1; %Bezier polynomials have m terms for m-1 order

fcn = zeros(n,y);
for k = 0:1:m
    fcn = fcn + coeff(:,k+1)*singleterm_bezier(m,k,s);
end

return
    
function val = singleterm_bezier(m,k,s)
  
if (k == 0)
    val = nchoosek(m,k).*(1-s).^(m-k);
elseif (m == k)
    val = nchoosek(m,k)*s.^(k);
else
    val = nchoosek(m,k)*s.^(k).*(1-s).^(m-k);
end

return