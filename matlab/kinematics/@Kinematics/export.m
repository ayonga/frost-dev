function status = export(obj, export_path, do_build)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files.
    %
    % Parameters:
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    %  do_build: determine whether build the mex files.
    %  @type logical  @default true
    %
    % Return values:
    % status: indicator of successful export/built process @type logical
    
    if nargin < 3
        do_build = true;
    end
    
    
    
    status = false;
    
    if ~(exist(export_path,'dir'))
        warning(['The path to export functions does not exist: %s\n',...
            'Please ensure to create the folder, and call this function again.\n',...
            'Aborting ...\n'], export_path);
        return;
    end
    % For windows, use ''/' instead of '\'. Otherwise mathematica does
    % not recognize the path.
    if ispc
        export_path = strrep(export_path, '\','/');
    end
    
    
    symbols = obj.Symbols;
    funcs   = obj.Funcs;
    
    if ~ check_var_exist(struct2cell(symbols))
        warning(['The kinematic expression has not been compiled in Mathematica.\n',...
            'Please call %s first\n',...
            'Aborting ...\n'],'compileKinematics(domain, model)');
        return;
    end
    
    
    
    
    eval_math('Needs["MathToCpp`"];');
    
    % necessary settings
    eval_math(['SetOptions[CseWriteCpp,',...
        'ExportDirectory->',str2mathstr(export_path),',',...
        'Namespace->Kinematics,',...
        'SubstitutionRules->GetStateSubs[]];']);
    eval_math('nDof=First@GetnDof[]');
    
    
    sym_expr_dim = math('math2matlab',['Dimensions[',symbols.Kin,']']);
    kin_dim = getDimension(obj);
    assert(kin_dim == sym_expr_dim, ...
        'Domain:invalidsize',...
        ['The dimension of the symbolic expression is %d.\n',...
        'It should be %d.'],sym_expr_dim,kin_dim);
    
    
    % if exists, export the function
    eval_math(['CseWriteCpp[',str2mathstr(funcs.Kin),',{',symbols.Kin,'},',...
        'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
    
    fprintf('File  %s.cc has been exported to %s\n', funcs.Kin, export_path);
    
    
    eval_math(['CseWriteCpp[',str2mathstr(funcs.Jac),',{',symbols.Jac,'},',...
        'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
    
    fprintf('File  %s.cc has been exported to %s\n', funcs.Jac, export_path);
    
    
    eval_math(['CseWriteCpp[',str2mathstr(funcs.JacDot),',{',symbols.JacDot,'},',...
        'ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]']);
    
    fprintf('File  %s.cc has been exported to %s\n', funcs.JacDot,export_path);
    % build mex file
    if do_build
        build_mex(export_path,struct2cell(funcs));
    end
    
    
   
    
    
    
end
