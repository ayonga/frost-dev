%> @brief Convert a general scalar struct to a string
%> @author Eric Cousineau <eacousineau@gmail.com>, AMBER Lab, under Dr.
%> Aaron Ames
%> @param s structure
%> @param varargin Arguments to propagate to general2str()
function [str] = struct2str(s, varargin)
fields = fieldnames(s);
nfield = length(fields);

field_strs = cell(nfield, 1);
for i = 1:nfield
    field = fields{i};
    field_str = general2str(field);
    value = s.(field);
    value_str = general2str(value, varargin{:});
    if iscell(value)
        % Use double-braces to prevent a struct array from being created
        value_str = ['{', value_str, '}'];
    end
    field_strs{i} = [field_str, ', ', value_str];
end

str = ['struct( ...\n', ...
    indent(strjoin(field_strs(:)', ', ...\n'), '\t'), ...
    ' ...\n)'];
end
