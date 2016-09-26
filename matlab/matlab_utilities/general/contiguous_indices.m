%> @brief Return a set of indices separating contiguous segments of logical
%> values.
%> @author Eric Cousineau <eacousineau@gmail.com>
function [C] = contiguous_indices(B)

% Following: http://stackoverflow.com/q/2212201/170413
B = logical(B(:)');
count = length(B);

if all(B)
    % Special case for all values being high
    C = {1:count};
    return;
end

dB = diff(B);
starts = find(dB == 1) + 1;
ends = find(dB == -1);

% If we start high, then we need to insert an initial index
if length(ends) >= 1 && (isempty(starts) || ends(1) < starts(1))
    starts = [1, starts];
end

% The count for ends and starts may differ if there is a lone point at the
% end
if length(starts) > length(ends)
    if isempty(ends) || starts(end) > ends(end)
        % Means we ended at transition going from low to high
        ends(end + 1) = count;
    else
        % Augment ends with last starting point
        ends(end + 1) = starts(end);
    end
end

nranges = length(ends);
C = cell(1, nranges);
for i = 1:nranges
    C{i} = starts(i):ends(i);
end

end
