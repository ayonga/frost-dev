%> @brief cellexpand Expand a cell (or array) value into the output
%> arguments. Similar to deal(), but only accepts one input argument.
%> @param X Cell or matrix vector to be distributed to varargout
function [varargout] = cellexpand(X)

if ismatrix(X)
    X = num2cell(X);
end

assert(iscell(X));
assert(isvector(X));
assert(length(X) == nargout);

varargout = X;

end
