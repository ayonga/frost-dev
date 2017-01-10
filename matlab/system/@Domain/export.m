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
    
    
    
    
    hol_symbols = obj.HolSymbols;
    
    if ~ check_var_exist(struct2cell(hol_symbols))
        warning(['The robot dynamics has not been compiled in Mathematica.\n',...
            'Please call %s first\n',...
            'Aborting ...\n'],'compileKinematics(domain, model)');
        return;
    end
    
    
    
    
    eval_math('Needs["MathToCpp`"];');
    
    % necessary settings
    eval_math(['SetOptions[CseWriteCpp,',...
        'ExportDirectory->',str2mathstr(export_path),',',...
        'Namespace->',str2mathstr(obj.Name),',',...
        'SubstitutionRules->GetStateSubs[]];']);
    eval_math('nDof=First@GetnDof[]');
    
    
    hol_constr_size = math('math2matlab',['Dimensions[',hol_symbols.Kin,']']);
    assert(obj.HolonomicDimension == hol_constr_size, ...
        'Domain:invalidsize',...
        ['The dimension of the holonomic constraint expression is %d.\',...
        'It should be %d.'],hol_constr_size,obj.HolonomicDimension);
    
    
     % if exists, export the function
     eval_math(['CseWriteCpp[',str2mathstr(obj.HolFuncs.Kin),',{',hol_symbols.Kin,'},',...
         'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
     
     fprintf('File  %s.cc has been exported to %s\n', obj.HolFuncs.Kin, export_path);
     
     
     eval_math(['CseWriteCpp[',str2mathstr(obj.HolFuncs.Jac),',{',hol_symbols.Jac,'},',...
         'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
     
     fprintf('File  %s.cc has been exported to %s\n', obj.HolFuncs.Jac, export_path);
     
     
     eval_math(['CseWriteCpp[',str2mathstr(obj.HolFuncs.JacDot),',{',hol_symbols.JacDot,'},',...
         'ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]']);
     
     fprintf('File  %s.cc has been exported to %s\n', obj.HolFuncs.JacDot,export_path);
     % build mex file
     if do_build
         build_mex(export_path,struct2cell(obj.HolFuncs));
     end
    
    
   
    
    % kinematic type of unilateral constraints
    unl_kin_objects = obj.UnilateralConstr{strcmp('Kinematic',obj.UnilateralConstr.Type),'KinObject'};
    if ~isempty(unl_kin_objects)        
        unl_kin_funcs = obj.UnilateralConstr{strcmp('Kinematic',obj.UnilateralConstr.Type),'KinFunction'};
        for i=1:numel(unl_kin_objects)
            kin_symbols = unl_kin_objects{i}.Symbols;
            kin_funcs = unl_kin_funcs{i};
            if ~ check_var_exist(struct2cell(kin_symbols))
                warning('The robot dynamics has not been compiled in Mathematica.\n');
                warning('Please call compileKinematics(domain, model) first\n');
                warning('Aborting ...\n');
                return;
            end
            
            % if exists, export the function
            eval_math(['CseWriteCpp[',str2mathstr(kin_funcs.Kin),',{',kin_symbols.Kin,'},',...
                'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
            
            fprintf('File  %s.cc has been exported to %s\n', kin_funcs.Kin, export_path);
            
            
            eval_math(['CseWriteCpp[',str2mathstr(kin_funcs.Jac),',{',kin_symbols.Jac,'},',...
                'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
            
            fprintf('File  %s.cc has been exported to %s\n', kin_funcs.Jac, export_path);
            
            
            eval_math(['CseWriteCpp[',str2mathstr(kin_funcs.JacDot),',{',kin_symbols.JacDot,'},',...
                'ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]']);
            
            fprintf('File  %s.cc has been exported to %s\n', kin_funcs.JacDot, export_path);
            % build mex file
            if do_build
                build_mex(export_path,struct2cell(kin_funcs));
            end
            
        end
    end
    
end
