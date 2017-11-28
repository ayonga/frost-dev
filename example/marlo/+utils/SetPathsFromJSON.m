function SetPathsFromJSON(data)
    for i = 1:length(data.withoutsubfolders)
        addpath(data.withoutsubfolders{i});
    end
    
    for i = 1:length(data.withsubfolders)
        addpath(genpath(data.withsubfolders{i}));
    end
end
