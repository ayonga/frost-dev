function [] = spatial_v2_init()
base_path = fileparts(mfilename('fullpath'));

deps = {'3D', 'dynamics', 'spatial', 'custom'};
count = length(deps);
for i = 1:count
    dep = deps{i};
    dep_path = fullfile(base_path, dep);
    addpath(dep_path);
end

end
