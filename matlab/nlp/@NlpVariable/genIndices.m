function obj = genIndices(obj, index_offset)
    % Generates indinces of each variable if the input is an array
    % of NlpVariable objects.
    %
    % Parameters:
    %  obj: an array of NlpVariable objects @type NlpVariable
    %  index_offset: the offset of the starting index of the variable
    %  array indices @type integer

    % get the size of object array
    num_obj = numel(obj);

    % If an offset is not specified, set it to zero.
    if nargin < 2
        index_offset = 0;
    end

    for i = 1:num_obj
        % set the index
        obj(i).Indices = index_offset + cumsum(ones(obj(i).Dimension, 1));

        % increments (updates) offset
        index_offset = index_offset + obj(i).Dimension;
    end
end