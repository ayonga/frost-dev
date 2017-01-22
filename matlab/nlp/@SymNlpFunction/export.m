function status = export(obj, export_path, do_build, derivative_level)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files.
    %
    %
    % Parameters:
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    %  do_build: determine whether build the mex files.
    %  @type logical  @default true
    %  derivative_level: determines the level of derivatives to be exported
    %  (1, 2) @type double
    %
    % Return values:
    % status: indicator of successful export/built process @type logical
    
    if nargin < 3
        do_build = true;
    end
    if nargin < 4
        derivative_level = 1;
    end
    
    
    
    status = false;
    if ~(exist(export_path,'dir'))
        warning(['The path to export functions does not exist: %s\n',...
            'Please ensure to create the folder, and call this function again.\n',...
            'Aborting ...\n'], export_path);
        return;
    end
    
    
    
    if isempty(obj.Expression)
        error('The kinematic ''Expression'' is not assigned.');
    end
    eval_math([obj.Symbols,'=',obj.Expression,';']);
    
    
    
    
    eval_math('Needs["MathToCpp`"];');
    
    
    
    % necessary settings
    eval_math(['SetOptions[CseWriteCpp,',...
        'ExportDirectory->',str2mathstr(export_path),'];']);
    
    if derivative_level == 1
        if isempty(obj.AuxData)
            eval_math(['ExportWithGradient[',str2mathstr(obj.Name),',',obj.Symbols,',{',...
                obj.DepSymbols{:},'}];']);
        else
            eval_math(['ExportWithGradient[',str2mathstr(obj.Name),',',obj.Symbols,',',...
                obj.DepSymbols{:},'},{',obj.ParSymbols,'}];']);
        end
        
        funcs = {['f_', obj.Name]
            ['J_', obj.Name]
            ['Js_', obj.Name]};
    elseif derivative_level == 2
        if isempty(obj.AuxData)
            eval_math(['ExportWithHessian[',str2mathstr(obj.Name),',',obj.Symbols,',{',...
                obj.DepSymbols{:},'}];']);
        else
            eval_math(['ExportWithHessian[',str2mathstr(obj.Name),',',obj.Symbols,',',...
                obj.DepSymbols{:},'},{',obj.ParSymbols,'}];']);
        end
        funcs = {['f_', obj.Name]
            ['J_', obj.Name]
            ['Js_', obj.Name]
            ['H_', obj.Name]
            ['Hs_', obj.Name]};
    end
    
    
    
    
    % build mex file
    if do_build
        build_mex(export_path,funcs);
    end
    
    status = true;
    
    
    
    
end
