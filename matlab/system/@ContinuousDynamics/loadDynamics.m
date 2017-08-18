function obj = loadDynamics(obj, path, varargin)
% export the symbolic expressions of the system dynamics matrices and
% vectors and compile as MEX files.
%
% Parameters:
%  export_path: the path to export the file @type char
%  varargin: variable input parameters @type varargin
%   StackVariable: whether to stack variables into one @type logical
%   File: the (full) file name of exported file @type char
%   ForceExport: force the export @type logical
%   BuildMex: flag whether to MEX the exported file @type logical
%   Namespace: the namespace of the function @type char
%   NoPrompt: answer yes to all prompts

[folder,file,ext] = fileparts(path);


assert(exist(path,'file')==2,'Dynamics file "%s" not found in "%s"',[file,ext],folder);

loadString = ['Get[','"',path,'"','];'];

eval_math(loadString);

end