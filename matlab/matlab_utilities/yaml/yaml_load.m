function [obj] = yaml_load(str, toMatrix, dirPath, useStructArrays)
%yaml_load Read YAML file, returning the corresponding data from SnakeYaml.
%  toMatrix - Set to true if you want this to recurse through all of your
%data and attempt to convert it to cell matrices. Only use this if you are
%sure your input will be uniform, otherwise you will be writing a lot of
%checks.

% Original: http://code.google.com/p/yamlmatlab/
% Modified by: Eric Cousineau [ eacousineau@gmail ]

%TODO Modify logic to keep structure arrays as cells, then later convert
%them in 'cell_to_matrix_scan'? Would make sense. Can add 'doStruct' flag
%to those funcs as well.

% The original code performs import deflating, but that is not
% implemented here yet.

if nargin < 2 || isempty(toMatrix)
	toMatrix = false;
end
if nargin < 3
	dirPath = [];
end
if nargin < 4 || isempty(useStructArrays)
    useStructArrays = true;
end

obj = load_yaml_str(str, dirPath);

if toMatrix
	% Have to start from top-level
	obj = cell_to_matrix_scan(obj);
end

%% Loading
	

	function result = load_yaml_str(raw, dirPath)
		persistent yaml
		if isempty(yaml)
			yaml = org.yaml.snakeyaml.Yaml();
		end
		
		pathstore = pwd();
		if nargin < 2 || isempty(dirPath)
			dirPath = pathstore;
        end
        % cd(dirPath); % Ignore this for now
		try
			result = scan(yaml.load(raw));
		catch ex
			cd(pathstore);
			rethrow(ex);
		end
		cd(pathstore);
	end

	function result = scan(r)
		% Recursive scanning
		if isa(r, 'char')
			result = char(r);
		elseif isa(r, 'double')
			result = double(r);
		elseif isa(r, 'logical')
			result = logical(r);
		elseif isa(r, 'java.util.Date')
			result = DateTime(r);
		elseif isa(r, 'java.util.List')
			result = scan_list(r);
		elseif isa(r, 'java.util.Map')
			result = scan_map(r);
		else
			error('Unknown data type: %s', class(r));
		end;
	end

%% List
	function result = scan_list(list)
		% Changed to allow for struct arrays.
		count = list.size();
		result = [];
		iter = list.iterator();
		index = 1;
		while iter.hasNext()
			raw = iter.next();
			elem = scan(raw);
			if isstruct(elem) && useStructArrays
                %%TODO This won't allow for non-struct stuff to follow... Oh well
				% Set up
				if index == 1
					% Copy struct structure but not data
					result = blank_struct(elem, count, 1);
                    result(index) = elem;
                else
                    result = struct_assign_loose(result, elem, index);
                end
			else
				if index == 1
					result = cell(count, 1);
				end
				result{index} = scan(raw);
			end
			index = index + 1;
		end
	end

%% Map
	function result = scan_map(map)
		result = struct();
		iter = map.entrySet().iterator();
		while iter.hasNext()
			entry = iter.next();
            key = char(entry.getKey());
            value = scan(entry.getValue());
			if strcmp(key, 'import')
				value = perform_import(value);
            end
            % SnakeYaml allows duplicate keys :/
            %assert(~isfield(result, key), 'yaml_load', 'Duplicate key: %s', key);
			result.(key) = value;
        end
	end

	function [result] = perform_import(r)
		%TODO Test this... Using relative directory?
		if ischar(r)
			result = {load_yaml(r)};
		elseif iscell(r) && all(cellfun(@ischar, r))
			result = cellfun(@load_yaml, r, 'UniformOutput', 0);
		else
			disp('Import Error for:');
			disp(r);
			error('Invalid filename(s).');
		end
	end
end