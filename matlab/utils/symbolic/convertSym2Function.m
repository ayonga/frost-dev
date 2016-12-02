
function h = convertSym2Function(func, outputs, vars, targetFuncName, sourceFile)
%convertSym2Function
% Description - convert symbolic expression 'func' to matlab function in
% file named 'targetFuncName.m' using 'vars' and 'outputs' as the input
% and output arguments of the function and return the function handle of 
% that function. If the target file already exists
% and newer than the 'sourceFile', then skip the generation process and
% just create a function handle of the target file.
%
% Copyright 2014-2015 Texas A&M University AMBER Lab
% Author: Ayonga Hereid <ayonga@tamu.edu>

% get source file info
source = dir(fullfile(sourceFile));
% get target function info
target = dir(fullfile(['expr/',targetFuncName,'.m']));
if ~isempty(target)
    % if the target file already exists
    % Obtain creation dates of files
    dateTarget = datenum(target.date);
    dateConfig = datenum(source.date);
    
    % compare the creation date of both files to decide how to
    % do next
    if dateTarget < dateConfig
        % If the target file is older than the configuration file
        % then create a new matlab function file, and assign the
        % function handle to the varibale
        h = matlabFunction(func, 'file',['expr/',targetFuncName],...
            'outputs', outputs, 'vars', vars);
    else
        % If the target file is newer than the configuration file
        % then do not need to create a new file, just assign the
        % function handle to the varibale
        h = str2func(targetFuncName);
    end
else
    % if the target file does not exist
    % then create a new file, and return the function handle
    h = matlabFunction(func, 'file',['expr/',targetFuncName],...
        'outputs',outputs, 'vars', vars);
end
end