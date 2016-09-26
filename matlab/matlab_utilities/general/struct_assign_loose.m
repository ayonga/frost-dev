function [list] = struct_assign_loose(list, elem, index)
% Makes sure that mis-matching field names and order do not screw up a
% struct array.
% Useful for loading YAML files.

if nargin < 3
    index = [];
end

assert(isscalar(elem));

if isempty(list) && isnumeric(list) && isempty(index)
    % Just set the list to the item and move on
    list = elem;
    return;
end

listFields = fieldnames(list);
elemFields = fieldnames(elem);

% Make space for new fields
listDontHave = setdiff(elemFields, listFields);
for i = 1:length(listDontHave)
    list().(listDontHave{i}) = [];
end

% Append the new struct to the list, using the original's structure
if isempty(index)
    index = length(list) + 1; % Use dynamic resizing
end

for i = 1:length(elemFields)
    field = elemFields{i};
    list(index).(field) = elem.(field);
end

end