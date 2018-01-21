function [myfun] = checkFun(fun,solver,name)
% Check function is a string or function handle.
% Optionally, check function has correct number of output arguments.
% Return the function handle.
%
% myfun = checkFun(fun,solver,name)
% myfun = checkFun(fun,solver,name,nouts)
%
errID = [solver ':InputArgs'];

if ischar(fun),
  myfun = str2func(fun);
elseif isa(fun,'function_handle'),
  myfun = fun;
else
  error(errID,'%s should be a function handle or string',name);
end
