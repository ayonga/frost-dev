%> @brief Catkin-style basic dependencies from matlab_utilities
%> @param vararigin List of subdirectories to add to the Matlab path
%> Each dependency must be a subdirectory under this one.
function [] = addpath_thirdparty_packages(varargin)

% Get path of this file
base_path = fileparts(mfilename('fullpath'));

for i = 1:nargin
    dep = varargin{i};
    
%     if strcmp(dep,'yaml')
%         jcp = fullfile(prefdir,'javaclasspath.txt');
%         jcpID = fopen(jcp,'a');
%         fprintf(jcpID,...
%             [fullfile(pwd,'third','yaml','snakeyaml-1.10.jar')]...
%             );
%         fclose(jcpID);
%     end
    % Check then add path
    dep_path = fullfile(base_path, dep);
    assert(isdir(dep_path), 'Invalid dependency (directory does not exist): %s', dep_path);
    addpath(dep_path);
    
    % Check for specific initialization
    init_path = fullfile(dep_path, [dep, '_init.m']);
    if exist(init_path, 'file')
        % Invoke initialization function
        feval([dep, '_init']);
    end
end

end
