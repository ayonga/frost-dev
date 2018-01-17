function [] = spatial_init()
base_path = fileparts(mfilename('fullpath'));

deps = {'3D', 'dynamics', 'spatial'};
count = length(deps);
for i = 1:count
    dep = deps{i};
    dep_path = fullfile(base_path, dep);
    addpath(dep_path);
end

end
