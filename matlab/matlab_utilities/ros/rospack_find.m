function [pkgPath] = rospack_find(pkgName)

[status, stdout] = system(sprintf('rospack find %s', pkgName));
if status == 0
    pkgPath = strtrim(stdout);
else
    error('rospack:find', 'rospack not found, or package does not exist: %s', pkgName);
end

end
