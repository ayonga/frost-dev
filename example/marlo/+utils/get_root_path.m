function [rootPath] = get_root_path()
    pathstr = mfilename('fullpath');
    [pathstr, ~, ~] = fileparts([pathstr, '.m']);
    [rootPath, ~, ~] = fileparts(pathstr);
end
