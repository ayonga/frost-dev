function setup_default_path()
% Script that setup all the environment variables for the project

% Add system related functions paths
cur = [fileparts(mfilename('fullpath')), '/'];



% Add useful custom functions path
addpath([cur, 'matlab_utilities/']);
addpath_matlab_utilities('general', ...
    'graphics', 'cwf', 'polynomial', 'sys', ...
    'ros', 'sim', 'plot', 'validation');

% Add third party packages/libraries path
addpath([cur, 'third/']);
addpath_thirdparty_packages('GetFullPath', 'date',...
    'sparse2', 'spatial_v2', 'strings', 'yaml');
end
