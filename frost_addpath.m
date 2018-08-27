function frost_addpath()

    % Add system related functions paths
    cur = fileparts(mfilename('fullpath'));

    if isempty(cur)
        cur = pwd;
    end 

    addpath(genpath(fullfile(cur, 'matlab')));
    addpath(fullfile(cur, 'matlab', 'nlp'));
    addpath(fullfile(cur, 'matlab', 'solver'));
    addpath(fullfile(cur, 'matlab', 'system'));
    addpath(fullfile(cur, 'matlab', 'control'));
    addpath(fullfile(cur, 'matlab', 'robotics'));
    % Add useful custom functions path
    addpath(fullfile(cur, 'matlab', 'utils'));
    addpath_matlab_utilities('general', 'mex', ...
        'graphics', 'mathlink', ...
        'sim', 'plot');

    % Add third party packages/libraries path
    addpath(fullfile(cur, 'third'));
    addpath_thirdparty_packages('GetFullPath', ...
        'mathlink', 'ipopt', 'sparse2', 'yaml', 'snopt');

    addpath(fullfile(cur, 'mathematica'));
    initialize_mathlink();

    addpath(fullfile(cur, 'example'));

    % warning('Restart Matlab to use the Snake yaml library.');
    % addpath(fullfile(cur, 'docs'));
end 
