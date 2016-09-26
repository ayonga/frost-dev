function [out] = vertcat_fields_domains(s, exclude_last)

if nargin < 2 || isempty(exclude_last)
    exclude_last = false;
end

out = struct();
fields = fieldnames(s);
count = length(fields);
for i = 1:count
    field = fields{i};
    if ismatrix(s(1).(field))
        x = vertcat_domains(exclude_last, s.(field));
        if exclude_last
            x(end, :) = [];
        end
        out.(field) = x;
    end
end

end
