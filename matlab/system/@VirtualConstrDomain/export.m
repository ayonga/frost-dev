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
    % For windows, use ''/' instead of '\'. Otherwise mathematica does
    % not recognize the path.
    if ispc
        export_path = strrep(export_path, '\','/');
    end
    
    status = false;
    %% kinematic constraints
    % call superclass method
    export@Domain(obj, export_path, do_build);
    
    %% phase variable
    % for non time-based outputs, compile phase variable
    if ~strcmp(obj.PhaseVariable.Type, 'TimeBased')
        export(obj.PhaseVariable.Var, export_path, do_build);
    end
   
    %% velocity output
    % if a velocity modulating output is defined
    if ~isempty(obj.ActVelocityOutput)
        export(obj.ActVelocityOutput, export_path, do_build);
        
        symbols = obj.DesVelocityOutput.Symbols;
        funcs   = obj.DesVelocityOutput.Funcs;
        [~, n_param] = obj.getDesOutputExpr(obj.DesVelocityOutput.Type);
        eval_math(['ParamSubs = Join[((a[#+1]->HoldForm@Global`v[[#]]&)/@(Range[',...
            num2str(n_param),']-1))];']);
        eval_math(['SetOptions[CseWriteCpp,',...
            'ExportDirectory->',str2mathstr(export_path),',',...
            'SubstitutionRules->ParamSubs];']);
        
        eval_math(['CseWriteCpp[',str2mathstr(funcs.y),',{',symbols.y,'},',...
            'ArgumentLists->{t, v},ArgumentDimensions->{{1,1},{',num2str(n_param),',1}}]']);
        
        fprintf('File  %s.cc has been exported to %s\n', funcs.y, export_path);
        
        eval_math(['CseWriteCpp[',str2mathstr(funcs.dy),',{',symbols.dy,'},',...
            'ArgumentLists->{t, v},ArgumentDimensions->{{1,1},{',num2str(n_param),',1}}]']);
        
        fprintf('File  %s.cc has been exported to %s\n', funcs.dy, export_path);
        % build mex file
        if do_build
            build_mex(export_path,struct2cell(funcs));
        end
    end
    
    %% position output
    % check if position modulating outputs are defined.
    if isempty(obj.ActPositionOutput)
        error('The position modulating output is empty. Configure the output before run the compile function');
    end
    % actual outputs
    export(obj.ActPositionOutput, export_path, do_build);
    % desired outputs
    symbols = obj.DesPositionOutput.Symbols;
    funcs   = obj.DesPositionOutput.Funcs;
    [~, n_param] = obj.getDesOutputExpr(obj.DesPositionOutput.Type);
    n_output = getDimension(obj.ActPositionOutput);
    
    eval_math(['ParamSubs = Join[{t-> HoldForm@t[[0]]},((a[#+1]->HoldForm@Global`a[[#]]&)/@(Range[',...
        num2str(n_param*n_output),']-1))];']);
    eval_math(['SetOptions[CseWriteCpp,',...
        'ExportDirectory->',str2mathstr(export_path),',',...
        'SubstitutionRules->ParamSubs];']);
    
    % if exists, export the function
    eval_math(['CseWriteCpp[',str2mathstr(funcs.y),',{',symbols.y,'},',...
        'ArgumentLists->{t, a},ArgumentDimensions->{{1,1},{',num2str(n_param*n_output),',1}}]']);
    
    fprintf('File  %s.cc has been exported to %s\n', funcs.y, export_path);
    
    eval_math(['CseWriteCpp[',str2mathstr(funcs.dy),',{',symbols.dy,'},',...
        'ArgumentLists->{t, a},ArgumentDimensions->{{1,1},{',num2str(n_param*n_output),',1}}]']);
    
    fprintf('File  %s.cc has been exported to %s\n', funcs.dy, export_path);
    
    eval_math(['CseWriteCpp[',str2mathstr(funcs.ddy),',{',symbols.ddy,'},',...
        'ArgumentLists->{t, a},ArgumentDimensions->{{1,1},{',num2str(n_param*n_output),',1}}]']);
    
    fprintf('File  %s.cc has been exported to %s\n', funcs.ddy, export_path);
    
    % build mex file
    if do_build
        build_mex(export_path,struct2cell(funcs));
    end
end
