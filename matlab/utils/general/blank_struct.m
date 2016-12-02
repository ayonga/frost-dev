function [blank, fields] = blank_struct(elem, rows, cols)
%STRUCT_BLANK Simple function to copy struture (fields, no data) of given structure
%For parsing into struct arrays. Will make a struct array of (ros, cols),
%or same size as elem if no args specified.
if nargin < 2
	rows = size(elem, 1);
end
if nargin < 3
	cols = size(elem, 2);
end
fields = fieldnames(elem);
setup = cell(length(fields) * 2, 1);
setup(1:2:end) = fields;
blank = repmat(struct(setup{:}), rows, cols);
end