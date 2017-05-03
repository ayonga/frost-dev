function [str] = yaml_write_file(filePath, obj, rowOnly)
%yaml_write_file Write 'obj' as YAML document to given 'filename', returns
%string representation.
%  rowOnly - if a numeric or cell array is a vector (size along one
%dimension is one) just put them all as row-vectors to keep things consistent.

% Original: http://code.google.com/p/yamlmatlab/
% Modified by: Eric Cousineau [ eacousineau@gmail ]

if nargin < 3
	rowOnly = [];
end

str = yaml_dump(obj, rowOnly);

fid = fopen(filePath, 'w');
fprintf(fid, '%s\n','domain:');
fprintf(fid, '%s', str);
fclose(fid);

end