function export(obj, export_path, derivative_level, do_build, reload)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files.
    %
    %
    % Parameters:         
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    %  derivative_level: determines the level of derivatives to be exported
    %  (0, 1, 2) @type double @default 0
    %  do_build: determine whether build the mex files.
    %  @type logical  @default true
    %  reload: recompile and export the symbolic functions @type logical
    
    if nargin < 5
        reload = false;
    end
    
    if obj.IsCompiled && ~reload
        return;
    end
    

    if nargin < 2
        export_path = pwd;
    end
    if ~(exist(export_path,'dir'))
        warning(['The path to export functions does not exist: %s\n',...
            'Please ensure to create the folder, and call this function again.\n',...
            'Aborting ...\n'], export_path);
        return;
    end
    
    
    if nargin < 3
        derivative_level = 0;
    end
    
    if nargin < 4
        do_build = false;
    end
        
    if isempty(obj.Vars) && isempty(obj.Params)
        vars = SymVariable('var'); % dummy variable
    elseif isempty(obj.Params)
        vars = obj.Vars;
    elseif isempty(obj.Vars)
        vars = obj.Params;
    else
        vars = {obj.Vars, obj.Params};
    end
    
    export_opts = struct(...
        'BuildMex', do_build,...
        'Namespace', string('SymNlpFunction'));
    
    
    if derivative_level >= 0
        % export the symbolic function 
        export_opts.Vars = vars;
        export_opts.File = fullfile(export_path, obj.Funcs.Func);
        export(obj.Expr, export_opts);
        
    end
    
    
    if derivative_level >= 1
        % export the first order Jacobian matrix
        jac = jacobian(obj.Expr, obj.Vars);
        
        % the non-zero values of the sparse Jacobian matrix
        jac_nonzeros = nonzeros(jac);
        export_opts.Vars = vars;
        export_opts.File = fullfile(export_path, obj.Funcs.Jac);
        export(jac_nonzeros, export_opts);
        
        % the non-zero positions of the sparse Jacobian matrix
        jac_nzind = nzind(jac);
        export_opts.Vars = SymVariable('var');
        export_opts.File = fullfile(export_path, obj.Funcs.JacStruct);
        export(jac_nzind, export_opts);
    end
    
    
    if derivative_level == 2
        % export the Hessian matrix
        hess = hessian(obj.Expr, obj.Vars);
        nexpr = length(obj.Expr);
        lambda = SymVariable('lambda',nexpr);
        
        hess_symbol = hess.s;
        lambda_symbol = lambda.s;
        
        cmd = ['Sum[' lambda_symbol '[[i]]*LowerTriangularize@' hess_symbol '[[i, ;;]], {i,' num2str(nexpr) '}]'];
        hess_sum = SymExpression(cmd);
        
        hess_nonzeros = nonzeros(hess_sum);
        export_opts.File = fullfile(export_path, obj.Funcs.Hess);
        export_opts.Vars = [vars, {lambda}];
        export(hess_nonzeros, export_opts);
        
        
        % the non-zero positions of the sparse Jacobian matrix
        hess_nzind = nzind(hess_sum);
        export_opts.Vars = SymVariable('var');
        export_opts.File = fullfile(export_path, obj.Funcs.HessStruct);
        export(hess_nzind, export_opts);
    end
    
   
    
    obj.IsCompiled = true;
    
    
    
end




