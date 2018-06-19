function file = export(obj, varargin)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files.
    %
    %
    % Parameters:
    %  varargin: variable input parameters @type varargin
    %   Vars: a list of symbolic variables @type SymVariable
    %   File: the (full) file name of exported file @type char
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type string
    %
    % Return values:
    %   file: the full file name of the exported function @type char
    
    eval_math('Needs["MathToCpp`"];');

    

    % process inputs
    N = getSyms(varargin);
    exprs = {obj, varargin{1:N}};    
    
    ip = inputParser;
    ip.addParameter('Vars',{},@isVars);
    ip.addParameter('File','',@isFunc);
    ip.addParameter('ForceExport',false,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('BuildMex',true,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('Namespace','SymExpression',@(x) ischar(x));
    ip.addParameter('TemplateFile','',@(x) ischar(x));
    ip.addParameter('TemplateHeader','',@(x) ischar(x));
    ip.addParameter('noPrompt',false,@(x) islogical(x));
    ip.parse(varargin{N+1:end});
    
    opts = ip.Results;
    
    assert(~isempty(opts.File),'The export destination file name must be specified explicitly.');
    assert(~isempty(opts.Vars),'Please specify the symbolic variables explicitly.');
    
    if (exist(opts.File,'file') == 2) && ~opts.ForceExport
        warning(['The file ''%s'' exists.\n',...
            'Set ''ForceExport'' to true in the argument list to force the export operation.\n',...
            'Aborting ...\n'], opts.File);
        file = opts.File;
        return;
    end
    
    if ~iscell(opts.Vars)
        args = {opts.Vars};
    else
        args = opts.Vars;
    end
    
    
    args = cell2tensor(args, 'ConvertString', false);
    
    
    
    % export directory
    [rel_path, filename] = fileparts(opts.File);
    export_path = GetFullPath(rel_path);
        
    if ~(exist(export_path,'dir')==7)
        error(['The path to export functions does not exist: %s\n',...
            'Please ensure to create the folder, and call this function again.\n',...
            'Aborting ...\n'], export_path);
    end
    % For windows, use '/' instead of '\'. Otherwise mathematica does
    % not recognize the path.
    if ispc
        export_path = strrep(export_path, '\','/');
    end
    % convert to string to keep the original string format when send to
    % Mathematica.
    cse_opts = struct();
    cse_opts.ExportDirectory = str2mathstr(export_path);
    cse_opts.Namespace= opts.Namespace;
    if ~isempty(opts.TemplateFile)
        [rel_path_template, filename_template, ext_template] = fileparts(opts.TemplateFile);
        template_path = GetFullPath(rel_path_template);
        template_path = strrep(template_path, '\','/');
        cse_opts.TemplateFile = str2mathstr([template_path, '/', filename_template, ext_template]);
    end
    if ~isempty(opts.TemplateHeader)
        [rel_path_template, filename_template, ext_template] = fileparts(opts.TemplateHeader);
        template_path = GetFullPath(rel_path_template);
        template_path = strrep(template_path, '\','/');
        cse_opts.TemplateHeader = str2mathstr([template_path, '/', filename_template, ext_template]);
    end
    % necessary settings
    cse_opts_str =  struct2assoc(cse_opts,'ConvertString',false);
    
    funcs = cell2tensor(cellfun(@(x)tomatrix(x), exprs, 'UniformOutput', false));
    
    fprintf('Generating: %s.cc\n', filename);
    
    eval_math(['ExportToCpp[' str2mathstr(filename) ',' funcs ',' args ', Normal@',cse_opts_str,']']);
    
    
    
    
    % build mex file
    if opts.BuildMex
        build_mex(export_path,filename);
        file = fullfile(export_path,[filename,'.cc']);       
    else
        file = [];
    end
    
    
    
end  
    
% find the index separating the functions from the option/value pairs
% return the last index of the functions, or 0 if none
function N = getSyms(args)
    chars = cellfun(@ischar,args) | cellfun(@isstruct,args);
    N = find(chars,1,'first');
    if isempty(N)
        N = length(args);
    else
        N = N-1;
    end
end
    



% validator for file parameter
function t = isFunc(x)
    [~,file] = fileparts(x);
    t = isvarname(file) || isempty(file);
end
% validator for variable parameter
function t = isVars(x)
    if iscell(x)
        if ~isvector(x) && ~isempty(x)
            error(['The ''Vars'' value must be a one-dimensional cell array of symbolic ',...
                'variables or an array of symbolic variables.']);
        end
        for k = 1:length(x)
            if ~isa(x{k},'SymVariable') 
                error(['The ''Vars'' value must be a one-dimensional cell array of symbolic ',...
                    'variables or an array of symbolic variables.']);
            end
        end
        t = true;
    elseif isa(x,'SymVariable')
        t = true;
    else
        error(['The ''Vars'' value must be a one-dimensional cell array of symbolic ',...
                'variables or an array of symbolic variables.']);
    end
end



    