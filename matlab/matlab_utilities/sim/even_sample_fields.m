function [out] = even_sample_fields(s,fs)

out = struct();
fields = fieldnames(s);
count = length(fields) - 1;
ts = s.t';
out.t = [];
for i = 1:count
    field = fields{i+1};
    xs = s.(field);
    if ~isnumeric(xs) || isempty(xs)
        continue;
    end
    [Et,Ex] = even_sample(ts,xs,fs);
    if size(Ex,2) == 1
        out.(field) = Ex';
    else
        out.(field) = Ex;
    end
end

out.t = Et;

end