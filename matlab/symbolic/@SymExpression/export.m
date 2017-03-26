function h = export(f, varargin)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files.
    %
    %
    % Parameters:
    %  f: the symbolic expression @type SymExpression
    %  varargin: variable input parameters @type varargin
    %   Vars: a list of symbolic variables @type SymVariable
    %   File: the (full) file name of exported file @type char
    %   BuildMex: flag whether to MEX the exported file @type logical
    %
    %
    % Return values:
    % h: a function handle to the exported function @type function_handle
    
    eval_math('Needs["MathToCpp`"];');

    

    % process inputs
    N = getSyms(varargin);
    exprs = {f, varargin{1:N}};    
    
    ip = inputParser;
    ip.addParameter('Vars',{},@isVars);
    ip.addParameter('File','',@isFunc);
    ip.addParameter('BuildMex',true,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('Namespace',string('namespace'),@isstring);
    ip.addParameter('ExportHeaderFile',true,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('ExportFull',true,@(x) isequal(x,true) || isequal(x,false));
    ip.parse(varargin{N+1:end});
    
    opts = ip.Results;
    
    assert(~isempty(opts.File),'The export destination file name must be specified explicitly.');
    assert(~isempty(opts.Vars),'Please specify the symbolic variables explicitly.');
    
    if ~iscell(opts.Vars)
        args = {opts.Vars};
    else
        args = opts.Vars;
    end
    
    
    args = cell2tensor(args, 'ConvertString', false);
    
    
    
    % export directory
    [rel_path, filename] = fileparts(opts.File);
    export_path = GetFullPath(rel_path);
        
    if ~(exist(export_path,'dir'))
        warning(['The path to export functions does not exist: %s\n',...
            'Please ensure to create the folder, and call this function again.\n',...
            'Aborting ...\n'], export_path);
        return;
    end
    % For windows, use '/' instead of '\'. Otherwise mathematica does
    % not recognize the path.
    if ispc
        export_path = strrep(export_path, '\','/');
    end
    % convert to string to keep the original string format when send to
    % Mathematica.
    cse_opts = struct();
    cse_opts.ExportDirectory = string(export_path);
    cse_opts.Namespace= opts.Namespace;
    cse_opts.ExportHeaderFile = opts.ExportHeaderFile;
    cse_opts.ExportFull = opts.ExportFull;
    % necessary settings
    cse_opts_str =  struct2assoc(cse_opts,'ConvertString',false);
    
    funcs = cell2tensor(cellfun(@(x)tomatrix(x), exprs, 'UniformOutput', false));
    
    
    eval_math(['ExportToCpp[' str2mathstr(filename) ',' funcs ',' args ', Normal@',cse_opts_str,']']);
    
    
    
    
    % build mex file
    if opts.BuildMex
        build_mex(export_path,filename);
        h = str2func(filename);
        addpath(export_path);
    else
        h = [];
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


function opts = getOptions(args)
    
end
    