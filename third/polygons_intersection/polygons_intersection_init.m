function [] = polygons_intersection_init()
base_path = fileparts(mfilename('fullpath'));

addpath_matlab_utilities('PolygonClipper');

deps = {'.'};
count = length(deps);
for i = 1:count
    dep = deps{i};
    dep_path = fullfile(base_path, dep);
    addpath(dep_path);
end

end
