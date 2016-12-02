function [out] = horzcat_fields_domains(s, skip_inconsistent, exclude_last)
if nargin < 2 || isempty(skip_inconsistent)
    skip_inconsistent = false;
end
if nargin < 3
    exclude_last = false;
end

out = struct();
fields = fieldnames(s);
count = length(fields);
for i = 1:count
    field = fields{i};
    if ismatrix(s(1).(field))
        try
		    x = horzcat_domains(s.(field));
		    if exclude_last
		        x(:, end) = [];
		    end
		    out.(field) = x;
        catch err
            if skip_inconsistent && strcmp(err.identifier, 'horzcat_donmains:constisency')
                % Do nothing
            else
                rethrow(err);
            end
        end
    end
end

end
