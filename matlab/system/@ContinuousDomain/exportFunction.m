function obj = exportFunction(obj, export_path, do_build, field_names)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files.
    %
    % Parameters:
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    %  do_build: determine whether build the mex files.
    %  @type logical  @default true
    %  field_names: specifies particular fields in the 'funcs' property
    %  that to be exported. If not specified explicitly, then
    %  compile all functions.
    
    if ~(exist(export_path,'dir'))
        fprintf('The path to export functions does not exist: %s\n', export_path);
        fprintf('Please ensure to create the folder, and call this function again.\n');
        fprintf('Aborting ...\n');
        return;
    end
    
    if nargin < 4
        %  If fields are not specified explicitly, set it to all
        %  fields of 'funcs'
        field_names = fields(obj.funcs);
    end
    
    if ischar(field_names)
        % if given as a string of single function, then converts to
        % a cell first.
        field_names = {field_names};
    end
    
    n_field = length(field_names);
    
    if n_field == 0
        return;
    end
    
    eval_math('Needs["MathToCpp`"];');
    
    % necessary settings
    eval_math(['SetOptions[CseWriteCpp,',...
        'ExportDirectory->',str2mathstr(export_path),',',...
        'Namespace->',str2mathstr(obj.name),',',...
        'SubstitutionRules->GetStateSubs[]];']);
    eval_math('nDof=First@GetnDof[]');
    
    for i=1:n_field
        field = field_names{i};
        
        switch field
            case 'hol_constr'
                % first make sures the corresponding symbolic expression have
                % been compilete in Mathematia.
                
                if check_var_exist(obj.hol_symbol) % check if the symbolic variable exists
                    
                    % if exists, export the function
                    eval_math(['CseWriteCpp[',str2mathstr(obj.funcs.hol_constr),',{',obj.hol_symbol,'},',...
                        'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
                    
                    fprintf('File  %s.cc has been exported to %s\n', obj.funcs.hol_constr,export_path);
                    
                    % build mex file
                    if do_build
                        build_mex(export_path,{obj.funcs.hol_constr});
                    end
                    
                else
                    error('The symbolic variable ''%s'' has not been assigned in Mathematica.\n',...
                        obj.hol_symbol);
                end
                
                
            case 'jac_hol_constr'
                % first make sures the corresponding symbolic expression have
                % been compilete in Mathematia.
                
                if check_var_exist(obj.hol_jac_symbol) % check if the symbolic variable exists
                    
                    % if exists, export the function
                    eval_math(['CseWriteCpp[',str2mathstr(obj.funcs.jac_hol_constr),',{',obj.hol_jac_symbol,'},',...
                        'ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]']);
                    
                    fprintf('File  %s.cc has been exported to %s\n', obj.funcs.jac_hol_constr,export_path);
                    
                    % build mex file
                    if do_build
                        build_mex(export_path,{obj.funcs.jac_hol_constr});
                    end
                else
                    error('The symbolic variable ''%s'' has not been assigned in Mathematica.\n',...
                        obj.hol_jac_symbol);
                end
                
            case 'jacdot_hol_constr'
                % first make sures the corresponding symbolic expression have
                % been compilete in Mathematia.
                
                if check_var_exist(obj.hol_jacdot_symbol) % check if the symbolic variable exists
                    
                    % if exists, export the function
                    eval_math(['CseWriteCpp[',str2mathstr(obj.funcs.jacdot_hol_constr),',{',obj.hol_jacdot_symbol,'},',...
                        'ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]']);
                    
                    fprintf('File  %s.cc has been exported to %s\n', obj.funcs.jacdot_hol_constr,export_path);
                    
                    % build mex file
                    if do_build
                        build_mex(export_path,{obj.funcs.jacdot_hol_constr});
                    end
                else
                    error('The symbolic variable ''%s'' has not been assigned in Mathematica.\n',...
                        obj.hol_jacdot_symbol);
                end
            otherwise
                warning(['The ''field_names'' must be a string or cell strings',...
                    'that match one of these strings:\n',...
                    '%s,\t'],fields(obj.funcs));
                
        end %switch
        
    end %if
    
    
    
end
