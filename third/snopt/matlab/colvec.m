function x = colvec(y,name,emptyOK,n)
% Return the column vector y.
% If it's a row vector, return the transpose.
% If it's netiher row or column, throw an error.
% If it's empty and it's not allowed, throw an error.
% If n > 0, check y has length n.
%

x = [];
if isempty(y),
  if ~emptyOK,
    s = ['Error: ', name, ' must be a non-empty row or column vector'];
    error(s);
  end
  return;
end

if iscolumn(y),
  x = y;
elseif isrow(y),
  x = y';
else
  s = ['Error: ', name, ' must be a row or column vector'];
  error(s);
end

if n > 0 && length(x) ~= n,
  s = ['Error: ', name, ' has to be of length ', num2str(n)];
  error(s);
end
