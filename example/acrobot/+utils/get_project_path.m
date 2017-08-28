function [pathstr] = get_project_path()
    pathstr = mfilename('fullpath');
    [pathstr, ~, ~] = fileparts([pathstr, '.m']);
    [pathstr, ~, ~] = fileparts([pathstr, '.m']);
end
