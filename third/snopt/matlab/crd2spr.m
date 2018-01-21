function [neA,indA,locA,valA] = crd2spr(A)
% Given matrix A, return A in sparse-by-column format
%

[m,n] = size(A);
neA   = 0; indA = []; locA = []; valA = [];

if ( m == 0 ),
  return;
end

[iA,jA,vA] = find(A);
neA        = numel(vA);

indA = zeros(neA,1);
valA = zeros(neA,1);
locA = zeros(n+1,1);

for k = 1:neA,
  j       = jA(k);
  locA(j) = locA(j) + 1;
end
locA(n+1) = neA+1;

for k = n:-1:1,
  locA(k) = locA(k+1) - locA(k);
end

for k = 1:neA,
  j  = jA(k);
  i  = iA(k);
  ii = locA(j);

  valA(ii) = vA(k);
  indA(ii) = i;
  locA(j)  = ii+1;
end

locA(2:n) = locA(1:n-1);
locA(1)   = 1;
