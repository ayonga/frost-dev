%> @brief Return a set of indices for monotonically increasing data set X
%> given slice points xi
%> @expect That X and xi are both sorted
%> @note Will be empty at the beginning
function [C, xs] = split_data(X, xi)
assert(issorted(X));
assert(issorted(xi));
len = length(X);

count = length(xi);
indices = nan(count, 1);
for i = 1:count
    indices(i) = find(X >= xi(i), 1, 'first');
end

C = split_indices(len, indices);
if nargout >= 2
    xs = cell(count + 1, 1);
    for i = 1:(count + 1)
        xs{i} = X(C{i});
    end
end

end
