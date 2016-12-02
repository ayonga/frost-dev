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
    
    if nargin < 3
        do_build = true;
    end
    
    if ~(exist(export_path,'dir'))
        fprintf('The path to export functions does not exist: %s\n', export_path);
        fprintf('Please ensure to create the folder, and call this function again.\n');
        fprintf('Aborting ...\n');
        status = false;
        return;
    end
    
    %     fprintf('Exporting expressions of rigid body dynamics might take very long time to finish!\n');
    %     y = input ('Hit enter to continue (or "n" to quit): ', 's');
    %
    %     if (isempty (y))
    %         y = 'y' ;
    %     end
    %     do_export = (y (1) ~= 'n') ;
    
    %     if ~ do_export
    %         fprintf('Aborting ...\n');
    %         status = false;
    %         return;
    %     else
    if ~obj.status.initialized
        fprintf('The robot model has NOT been initialized in Mathematica.\n');
        fprintf('Please call initialize(robot) first\n');
        fprintf('Aborting ...\n');
        status = false;
        return;
    else
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
        
        math('CseWriteCpp["pe_com_vec",{pcom},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
        
        math('CseWriteCpp["Je_com_mat",{Jcom},ArgumentLists->{q},ArgumentDimensions->{{nDof,1}}]');
        
        math('CseWriteCpp["dJe_com_mat",{dJcom},ArgumentLists->{q,dq},ArgumentDimensions->{{nDof,1},{nDof,1}}]');
        
        if do_build
            build_mex(export_path,{'pe_com_vec','Je_com_mat','dJe_com_mat'});
        end
        status = true;
    end
end
