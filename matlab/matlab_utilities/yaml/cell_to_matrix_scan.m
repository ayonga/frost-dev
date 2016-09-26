function [result] = cell_to_matrix_scan(data)
% Recurse through data (structs, cells, etc),
% converting sets of cell arrays to numeric matrices when possible, using cell_to_matrix()
% For cells and structs, only 1D arrays are produced.
% This needs to be called explicity, or at least be false by default.
% - Eric
if iscell(data)
	result = cell_to_matrix_scan_cell(data);
elseif isstruct(data)
	result = cell_to_matrix_scan_struct(data);
else
	% Leave everything else as is
	result = data;
end

	function [data] = cell_to_matrix_scan_cell(data)
		% See if cell itself can be converted
		% All cells will be 1D only, all numerics will be scalars
		[mat, good] = cell_to_matrix(data);
		if good
			data = mat;
		else
			for i = 1:length(data)
				data{i} = cell_to_matrix_scan(data{i});
			end
		end
	end

	function [data] = cell_to_matrix_scan_struct(data)
		count = length(data(:));
		fields = fieldnames(data);
		for i = 1:length(fields)
			field = fields{i};
			for j = 1:count
				data(j).(field) = cell_to_matrix_scan(data(j).(field));
			end
		end
	end
end