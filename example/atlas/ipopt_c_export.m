nlp.update;
solver = IpoptApplication(nlp);

addpath('~/Projects/C-Frost/Matlab/');

c_code_path = '~/Projects/C-Frost/Matlab/Atlas/c_code';
src_path = fullfile(c_code_path, 'src');
src_gen_path = fullfile(src_path, 'gen');
include_dir = fullfile(c_code_path, 'include');
data_path = fullfile(c_code_path, 'res');
COMPILE = true;
if ~exist(c_code_path, 'dir')
    mkdir(c_code_path);
end
if ~exist(src_path, 'dir')
    mkdir(src_path);
end
if ~exist(src_gen_path, 'dir')
    mkdir(src_gen_path);
end
if ~exist(include_dir, 'dir')
    mkdir(include_dir);
end
if ~exist(data_path, 'dir')
    mkdir(data_path);
end

[funcs] = frost_c.getAllFuncs(solver);
frost_c.createFunctionListHeader(funcs, src_path, include_dir);
frost_c.createIncludeHeader(funcs, include_dir);
if COMPILE
    frost_c.createConstraints(nlp,[],[],src_gen_path, include_dir)
    frost_c.createObjectives(nlp,[],[],src_gen_path, include_dir)
end
frost_c.createDataFile(solver, funcs, data_path);
frost_c.createInitialGuess(solver, data_path);

% copyfile('CMakeLists.txt', 'c_code/CMakeLists.txt');
% copyfile('default-ipopt.opt', 'c_code/ipopt.opt');


% if ~exist(fullfile(c_export_path, 'src/gen'),'dir')
%     mkdir(fullfile(c_export_path, 'src/gen'));
% end
% if ~exist(fullfile(c_export_path, 'include/frost/gen'),'dir')
%     mkdir(fullfile(c_export_path, 'include/frost/gen'));
% end
% if ~exist(fullfile(c_export_path, 'tmp'),'dir')
%     mkdir(fullfile(c_export_path, 'tmp'));
% end

% %%
% compileConst% %%
% compileConstraint(nlp,[],[],fullfile(frost_c.getRootPath,c_export_path,'tmp'), [],...
%     'ForceExport', true,...
%     'StackVariable', true,...
%     'BuildMex', false,...
%     'TemplateFile', fullfile(frost_c.getRootPath, 'templateMfalsein.c'),...
%     'TemplateHeader', fullfile(frost_c.getRootPath, 'templateMin.h'));
% compileObjective(nlp,[],[],fullfile(frost_c.getRootPath,c_export_path,'tmp'), [],...
%     'ForceExport', true,...
%     'StackVariable', true,...false
%     'BuildMex', false,...
%     'TemplateFile', fullfile(frost_c.getRootPath, 'templateMin.c'),...
%     'TemplateHeader', fullfile(frost_c.getRootPath, 'templateMin.h'));
% 
% movefile(fullfile(c_export_path, 'tmp','*hh'), fullfile(c_export_path, 'include/frost/gen/'));
% movefile(fullfile(c_export_path, 'tmp','*cc'), fullfile(c_export_path, 'src/gen/'));
% 
% %%
% addpath(genpath(export_path));
% nlp.update;
% solver = IpoptApplication(nlp);
% 
% %% Create files depending on solver
% if ~exist(fullfile(c_export_path, 'res'),'dir')
%     mkdir(fullfile(c_export_path, 'res'));
% end
% 
% [funcs, nums] = frost_c.getAllFuncs(solver);
% frost_c.createFunctionListHeader(funcs, nums, c_export_path);
% frost_c.createIncludeHeader(funcs, nums, c_export_path);
% frost_c.createJSONFile(solver, funcs, nums, c_export_path);
% 
% x0 = getInitialGuess(solver.Nlp, solver.Options.initialguess);
% if iscolumn(x0)
%     x0 = x0';
% end
% savejson('', x0, fullfile(c_export_path, 'res', 'init.json'))raint(nlp,[],[],fullfile(frost_c.getRootPath,c_export_path,'tmp'), [],...
%     'ForceExport', true,...
%     'StackVariable', true,...
%     'BuildMex', false,...
%     'TemplateFile', fullfile(frost_c.getRootPath, 'templateMfalsein.c'),...
%     'TemplateHeader', fullfile(frost_c.getRootPath, 'templateMin.h'));
% compileObjective(nlp,[],[],fullfile(frost_c.getRootPath,c_export_path,'tmp'), [],...
%     'ForceExport', true,...
%     'StackVariable', true,...false
%     'BuildMex', false,...
%     'TemplateFile', fullfile(frost_c.getRootPath, 'templateMin.c'),...
%     'TemplateHeader', fullfile(frost_c.getRootPath, 'templateMin.h'));
% 
% movefile(fullfile(c_export_path, 'tmp','*hh'), fullfile(c_export_path, 'include/frost/gen/'));
% movefile(fullfile(c_export_path, 'tmp','*cc'), fullfile(c_export_path, 'src/gen/'));
% 
% %%
% addpath(genpath(export_path));
% nlp.update;
% solver = IpoptApplication(nlp);
% 
% %% Create files depending on solver
% if ~exist(fullfile(c_export_path, 'res'),'dir')
%     mkdir(fullfile(c_export_path, 'res'));
% end
% 
% [funcs, nums] = frost_c.getAllFuncs(solver);
% frost_c.createFunctionListHeader(funcs, nums, c_export_path);
% frost_c.createIncludeHeader(funcs, nums, c_export_path);
% frost_c.createJSONFile(solver, funcs, nums, c_export_path);
% 
% x0 = getInitialGuess(solver.Nlp, solver.Options.initialguess);
% if iscolumn(x0)
%     x0 = x0';
% end
% savejson('', x0, fullfile(c_export_path, 'res', 'init.json'))