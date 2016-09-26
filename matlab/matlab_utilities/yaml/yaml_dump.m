function [str] = yaml_dump(obj, rowOnly, noFlow)
%yaml_dump Dump 'obj' to a Yaml string representation.
%  rowOnly - if a numeric or cell array is a vector (size along one
%dimension is one) just put them all as row-vectors to keep things consistent.

% Original: http://code.google.com/p/yamlmatlab/
% Modified by: Eric Cousineau [ eacousineau@gmail ]

%TODO Strip this down to improve performance

if nargin < 2 || isempty(rowOnly)
	rowOnly = true;
end
if nargin < 3 || isempty(noFlow)
    noFlow = false;
end

objScanned = scan(obj);

dumperopts = org.yaml.snakeyaml.DumperOptions();
dumperopts.setLineBreak(javaMethod('getPlatformLineBreak', ...
	'org.yaml.snakeyaml.DumperOptions$LineBreak'));
if noFlow
    dumperopts.setDefaultFlowStyle(javaMethod('valueOf', 'org.yaml.snakeyaml.DumperOptions$FlowStyle', 'BLOCK'));
end
yaml = org.yaml.snakeyaml.Yaml(dumperopts);

str = char(yaml.dump(objScanned));

	function [result] = scan(data)
		if islogical(data)
            if isscalar(data)
                result = scan_bool(data);
            else
                result = scan_numeric(data);
            end
        elseif isnumeric(data)
			result = scan_numeric(data);
		elseif ischar(data)
			result = scan_char(data);
		elseif iscell(data)
			result = scan_cell(data);
		elseif isstruct(data)
			result = scan_struct(data);
		elseif isa(data, 'Datetime')
			result = scan_datetime(r);
        elseif isa(data, 'function_handle')
            result = sprintf('@%s', func2str(data)); % No idea what else to do
		else
			error('Cannot handle type: %s', class(data));
		end
	end

%% Basic
	function result = scan_char(r)
		result = java.lang.String(r);
	end

	function result = scan_bool(r)
		result = java.lang.Boolean(r);
	end

	function result = scan_datetime(r)
		[Y, M, D, H, MN,S] = datevec(double(r));
		% Why M - 1? -Eric
		result = java.util.GregorianCalendar(Y, M - 1, D, H, MN,S);
		result.setTimeZone(java.util.TimeZone.getTimeZone('UTC'));
	end

%% Numeric
	function result = scan_numeric(r)
		if isempty(r)
			result = java.util.ArrayList();
		elseif isscalar(r)
            if isinteger(r)
                result = java.lang.Integer(r);
            else
                result = java.lang.Double(r);
            end
		elseif isvector(r) && (rowOnly || size(r, 1) == 1)
			result = scan_numeric_row(r);
		elseif ismatrix(r) && ndims(r) == 2
			result = scan_numeric_matrix(r);
		else
			error('Unknown ordinary array content.');
		end;
	end

	function result = scan_numeric_row(data)
		count = length(data);
		result = java.util.ArrayList(count);
		for i = 1:count
			result.add(scan_numeric(data(i)));
		end
	end

	function result = scan_numeric_matrix(data)
        %> @todo Add scanning of integer matrices
		count = size(data, 1);
		result = java.util.ArrayList(count);
		for i = 1:count
			result.add(scan_numeric_row(data(i, :)));
		end
	end

%% Cell
	function result = scan_cell(r)
		if isempty(r)
			result = java.util.ArrayList();
		elseif isscalar(r) || (isvector(r) && (rowOnly || size(r, 1) == 1))
			result = scan_cell_row(r);
		elseif ismatrix(r) && ndims(r) == 2
			result = scan_cell_matrix(r);
		else
			error('Unknown cell array content.');
		end;
	end

	function result = scan_cell_row(data)
		count = length(data);
		result = java.util.ArrayList(count);
		for i = 1:count
			result.add(scan(data{i}));
		end
	end

	function result = scan_cell_matrix(data)
		count = size(data, 1);
		result = java.util.ArrayList(count);
		for i = 1:count
			result.add(scan_cell_row(data(i, :)));
		end
	end

%% Struct
	function result = scan_struct(r)
		if isscalar(r)
			result = scan_struct_scalar(r);
		else
			count = length(r(:));
			result = java.util.ArrayList(count);
			for i = 1:length(r)
				result.add(scan_struct_scalar(r(i)));
			end
		end
	end

	function result = scan_struct_scalar(r)
		result = java.util.LinkedHashMap();
		for i = fields(r)'
			key = i{1};
			val = r.(key);
			result.put(key, scan(val));
		end
	end
end