function obj = exportDynamics(obj, export_path, do_build)
    % This function exports the symbolic expressions of natural
    % dynamics of the rigid body model into C++ function files.
    %
    % Parameters:
    %  export_path: the complete folder path where the compiled symbolic
    %  function will be exported @type char
    %  do_build: determine whether build the mex files. @type logical
    %  @default true
    %
    %
    % @attention initialize(obj) must be called before run this function.
    
    %     %  lists: a cell array that determines what functions to be exported.
    %     %  If not specified, then export all functions related to the natural
    %     %  dynamics of the system.
    %     %  @type cell
    
    if nargin < 3
        do_build = true;
    end
    
    if ~obj.status.initialized
        fprintf('The robot model has NOT been initialized in Mathematica.\n');
        fprintf('Please call initialize(robot) first\n');
        fprintf('Aborting ...\n');
        obj.status.exported_dynamics = false;
        return;
    end
    
    if ~obj.status.compiled_dynamics
        fprintf('The robot dynamics has not been compiled in Mathematica.\n');
        fprintf('Please call compileDynamics(robot) first\n');
        fprintf('Aborting ...\n');
        obj.status.exported_dynamics = false;
        return;
    end
    
    if ~(exist(export_path,'dir'))
        fprintf('The path to export functions does not exist: %s\n', export_path);
        fprintf('Please ensure to create the folder, and call this function again.\n');
        fprintf('Aborting ...\n');
        obj.status.exported_dynamics = false;
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
    
    
    if obj.status.exported_dynamics
        fprintf('The dynamics functions have been exported earlier. Do you wish to export them again?\n');
        y = input ('Hit enter to continue (or "n" to quit): ', 's');
    
        if (isempty (y))
            y = 'y' ;
        end
        
        if ~ (y (1) ~= 'n')
            fprintf('Aborting ...\n');
            return;
        end
    end
    
    math('Needs["MathToCpp`"];');
    
    
    % necessary settings
    math(['SetOptions[CseWriteCpp,',...
        'ExportDirectory->',str2math(export_path),',',...
        'Namespace->',str2math(obj.name),',',...
        'SubstitutionRules->GetStateSubs[]];']);
    math('nDof=First@GetnDof[]');
    
    assert(obj.n_dofs == math('math2matlab','{{nDof}}'), ...
        'The total number of DoF does not match.');
    % export compiled symbolic functions
    disp('Exporting De_mat ...');
    tic
    math('CseWriteCpp["De_mat",{De},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
    toc
    
    disp('Exporting Ce_mat ...');
    tic
    math('CseWriteCpp["Ce_mat",{Ce},ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]');
    toc
    
    disp('Exporting Ge_vec ...');
    tic
    math('CseWriteCpp["Ge_vec",{Ge},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
    toc
    
    if do_build
        disp('Building MEX files ...');
        build_mex(export_path,{'De_mat','Ge_vec','Ce_mat'});
    end
    
    
    obj.status.exported_dynamics = true;
    
end
