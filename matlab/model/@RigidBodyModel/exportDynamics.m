function status = exportDynamics(obj, export_path, do_build)
    % This function exports the symbolic expressions of natural
    % dynamics of the rigid body model into C++ function files.
    %
    % Parameters:
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    %  do_build: determine whether build the mex files. @type logical
    %  @default true
    %
    % Return values:
    % status: indicator of successful export/built process @type logical
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
    
    flag = '$ModelInitialized';
    
    
    if ~checkFlag(obj, flag)
        warning(['The robot model has NOT been initialized in Mathematica.\n',...
            'Please call initialize(robot) first. Aborting ...\n']);
        return;
    end
    
    if ~ check_var_exist({'De','Ce','Ge'})
        warning(['The robot dynamics has NOT been compiled in Mathematica.\n',...
            'Please call compileDynamics(robot) first. Aborting ...\n']);
        return;
    end
    
    if ~(exist(export_path,'dir'))
        warning(['The path to export functions does not exist: %s\n',...
            'Please ensure to create the folder, and call this function again.\n',...
            'Aborting ...\n'], export_path);
        return;
    end
    
    fprintf('Exporting expressions of rigid body dynamics might take very long time to finish!\n');
    y = input ('Hit enter to continue (or "n" to quit): ', 's');
    
    if (isempty (y))
        y = 'y' ;
    end
    
    if ~ (y (1) ~= 'n') 
        fprintf('Aborting ...\n');
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
    % export compiled symbolic functions
    if exist(fullfile(export_path,'De_mat.cc'),'file')
        fprintf('''De_mat.cc'' already exists in %s \n', export_path);
        fprintf('Do you wish to overwrite the existing file?  ');
        clear y;
        y = input ('Hit enter to continue (or "n" to quit): ', 's');
        
        if (isempty (y))
            y = 'y' ;
        end
        
        if ~ (y (1) ~= 'n')
            fprintf('Aborting ...');
        else
            disp('Exporting De_mat ...');
            tic
            eval_math('CseWriteCpp["De_mat",{De},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
            toc
        end
    else
        disp('Exporting De_mat ...');
        tic
        eval_math('CseWriteCpp["De_mat",{De},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
        toc
    end
        
    
    if exist(fullfile(export_path,'Ce_mat.cc'),'file')
        fprintf('''Ce_mat.cc'' already exists in %s \n', export_path);
        fprintf('Do you wish to overwrite the existing file?  ');
        clear y;
        y = input ('Hit enter to continue (or "n" to quit): ', 's');
        
        if (isempty (y))
            y = 'y' ;
        end
        
        if ~ (y (1) ~= 'n')
            fprintf('Aborting ...');
        else
            disp('Exporting Ce_mat ...');
            tic
            eval_math('CseWriteCpp["Ce_mat",{Ce},ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]');
            toc
        end
    else
        disp('Exporting Ce_mat ...');
        tic
        eval_math('CseWriteCpp["Ce_mat",{Ce},ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]');
        toc
    end
    
    if exist(fullfile(export_path,'Ge_vec.cc'),'file')
        fprintf('''Ge_vec.cc'' already exists in %s \n', export_path);
        fprintf('Do you wish to overwrite the existing file?  ');
        clear y;
        y = input ('Hit enter to continue (or "n" to quit): ', 's');
        
        if (isempty (y))
            y = 'y' ;
        end
        
        if ~ (y (1) ~= 'n')
            fprintf('Aborting ...');
        else
            disp('Exporting Ge_vec ...');
            tic
            eval_math('CseWriteCpp["Ge_vec",{Ge},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
            toc
        end
    else
        disp('Exporting Ge_vec ...');
        tic
        eval_math('CseWriteCpp["Ge_vec",{Ge},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
        toc
    end
    
    if do_build
        disp('Building MEX files ...');
        build_mex(export_path,{'De_mat','Ge_vec','Ce_mat'});
    end
    
    status = true;
    
end
