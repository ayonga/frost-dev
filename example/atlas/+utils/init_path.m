function init_path(export_path)
% initialize the path



if nargin > 0
    if ~exist(export_path,'dir')
        mkdir(export_path);
    end
    addpath(export_path);
end

end
