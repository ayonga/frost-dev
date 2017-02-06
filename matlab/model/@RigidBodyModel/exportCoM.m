function status = exportCoM(obj, export_path, do_build)
    % This function compile the symbolic expressions of CoM position and
    % its first order Jacobian of the rigid body model to C++ function files.
    %
    % Parameters:
    %  export_path: the complete folder path where the compiled symbolic
    %  function will be exported @type char
    %
    % Return values:
    %  status: the status of the operation. 'true' if succeed, 'false' if
    %  aborted or failed. @type logical
    %
    %
    % @attention initialize(obj) must be called before run this function.
    
    %     %  lists: a cell array that determines what functions to be exported.
    %     %  If not specified, then export all functions related to the natural
    %     %  dynamics of the system.
    %     %  @type cell
    
    status = false;
    if nargin < 3
        do_build = true;
    end
    
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
    
    flag = '$ModelInitialized';
    
    
    if ~checkFlag(obj, flag)
        warning(['The robot model has NOT been initialized in Mathematica.\n',...
            'Please call initialize(robot) first. Aborting ...\n']);
        return;
    end
    
    if ~ check_var_exist({'pcom','Jcom','dJcom'})
        warning(['The center of mass position has NOT been compiled in Mathematica.\n',...
            'Please call compileCoM(robot) first. Aborting ...\n']);
        return;
    end
    
    
    eval_math('Needs["MathToCpp`"];');
    
    
    
    
    % necessary settings
    eval_math(['SetOptions[CseWriteCpp,',...
        'ExportDirectory->',str2mathstr(export_path),',',...
        'Namespace->',str2mathstr(obj.Name),',',...
        'SubstitutionRules->GetStateSubs[]];']);
    eval_math('nDof=First@GetnDof[]');
    
    assert(obj.nDof == math('math2matlab','{{nDof}}'), ...
        'The total number of DoF does not match.');
    
    
    if exist(fullfile(export_path,'pe_com_vec.cc'),'file')
        fprintf('''pe_com_vec.cc'' already exists in %s \n', export_path);
        fprintf('Do you wish to overwrite the existing file?  ');
        clear y;
        y = input ('Hit enter to continue (or "n" to quit): ', 's');
        
        if (isempty (y))
            y = 'y' ;
        end
        
        if ~ (y (1) ~= 'n')
            fprintf('Aborting ...');
        else
            eval_math('CseWriteCpp["pe_com_vec",{pcom},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
        end
    else
        eval_math('CseWriteCpp["pe_com_vec",{pcom},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
    end
    % export compiled symbolic functions
    if exist(fullfile(export_path,'Je_com_mat.cc'),'file')
        fprintf('''Je_com_mat.cc'' already exists in %s \n', export_path);
        fprintf('Do you wish to overwrite the existing file?  ');
        clear y;
        y = input ('Hit enter to continue (or "n" to quit): ', 's');
        
        if (isempty (y))
            y = 'y' ;
        end
        
        if ~ (y (1) ~= 'n')
            fprintf('Aborting ...');
        else
            eval_math('CseWriteCpp["Je_com_mat",{Jcom},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
        end
    else
        eval_math('CseWriteCpp["Je_com_mat",{Jcom},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
    end
    
    
     % export compiled symbolic functions
    if exist(fullfile(export_path,'dJe_com_mat.cc'),'file')
        fprintf('''dJe_com_mat.cc'' already exists in %s \n', export_path);
        fprintf('Do you wish to overwrite the existing file?  ');
        clear y;
        y = input ('Hit enter to continue (or "n" to quit): ', 's');
        
        if (isempty (y))
            y = 'y' ;
        end
        
        if ~ (y (1) ~= 'n')
            fprintf('Aborting ...');
        else
            eval_math('CseWriteCpp["dJe_com_mat",{dJcom},ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]');
        end
    else
        eval_math('CseWriteCpp["dJe_com_mat",{dJcom},ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]');
    end
    
    
    if do_build
        build_mex(export_path,{'pe_com_vec','Je_com_mat','dJe_com_mat'});
    end
    
    status = true;
end
