function [result, good] = cell_to_matrix(data)
% Different than cell2mat, only handles 2D arrays
% Could just use cell2mat and catch error, but that would be slower
good = true;
if isempty(data)
	% Empty matrix instead of empty cell
	result = [];
else
	rows = length(data);
	if cell_isnumeric_all(data)
		result = zeros(rows, 1);
		for j = 1:rows
			result(j) = data{j};
		end
	else
		% Start out being hopeful
		cols = length(data{1});
		result = zeros(rows, cols);
		for i = 1:rows
			row = data{i};
			if ~cell_isnumeric_all(row, cols)
				good = false;
				result = [];
				return;
			end
			for j = 1:cols
				result(i, j) = row{j};
			end
		end
	end
end

	function [result] = cell_isnumeric_all(data, count)
		% Allow for count to short-circuit the logic
		result = false;
		if iscell(data)
			if nargin < 2 || length(data) == count
				result = all(cellfun(@isnumeric, data));
			end
		end
	end

end