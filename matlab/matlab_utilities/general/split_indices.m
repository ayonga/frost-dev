%> @brief Given N indices, split an array into a set of N+1 sets,
%> left-continuous (start with 1, then indices given)
%> @expect Input is sorted
%> @note May return empty sets
function [C] = split_indices(len, indices)
assert(issorted(indices));

count = length(indices);
C = cell(count + 1, 1);

C{1} = 1:(indices(1) - 1);
for i = 2:count
    C{i} = indices(i - 1):(indices(i) - 1);
end
C{end} = indices(end):len;

end
