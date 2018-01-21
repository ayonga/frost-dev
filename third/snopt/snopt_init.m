%> @brief Add snake yaml to the path for yaml functions to use it
function snopt_init()

cur = fileparts(mfilename('fullpath'));
addpath(fullfile(cur,'matlab'));
addpath(fullfile(cur,'mex'));

end
