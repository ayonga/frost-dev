%> @brief Add snake yaml to the path for yaml functions to use it
function [snakeYaml] = yaml_init()

snakeYaml = fullfile(fileparts(mfilename('fullpath')), 'snakeyaml-1.10.jar');

if ~any(strcmp(snakeYaml, javaclasspath('-all')))
    javaaddpath(snakeYaml);
end

addpath_matlab_utilities('general');

end
