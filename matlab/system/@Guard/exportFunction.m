function obj = exportFunction(obj, export_path, do_build)
    % Export the symbolic expression of the kinematic function to
    % C/C++ source files and build them as MEX files.
    %
    % Parameters:
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    %  do_build: determine whether build the mex files.
    %  @type logical  @default true
    
    
    if ~(exist(export_path,'dir'))
        fprintf('The path to export functions does not exist: %s\n', export_path);
        fprintf('Please ensure to create the folder, and call this function again.\n');
        fprintf('Aborting ...\n');
        return;
    end
    
    eval_math('Needs["MathToCpp`"];');
    
    % necessary settings
    eval_math(['SetOptions[CseWriteCpp,',...
        'ExportDirectory->',str2mathstr(export_path),',',...
        'Namespace->',str2mathstr(obj.name),',',...
        'SubstitutionRules->GetStateSubs[]];']);
    eval_math('nDof=First@GetnDof[]');
    
    if check_var_exist({['$h[',obj.funcs.pos,']'],['$Jh[',obj.funcs.jac,']']}) % check if the symbolic variable exists
        
        % if exists, export the function
        eval_math(['CseWriteCpp[',str2mathstr(obj.funcs.pos),',{',['$h[',obj.funcs.pos,']'],'},',...
            'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
        fprintf('File  %s.cc has been exported to %s\n', obj.funcs.pos,export_path);
        
        eval_math(['CseWriteCpp[',str2mathstr(obj.funcs.jac),',{',['$h[',obj.funcs.jac,']'],'},',...
            'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
        fprintf('File  %s.cc has been exported to %s\n', obj.funcs.jac,export_path);
        
        
        % build mex file
        if do_build
            build_mex(export_path,{obj.funcs.pos, obj.funcs.jac});
        end
        
    else
        error(['The symbolic variable of the guard object has not been assigned in Mathematica.\n',...
            '%s or %s.'], ['$h[',obj.funcs.pos,']'],['$Jh[',obj.funcs.jac,']']);
    end
    
end
