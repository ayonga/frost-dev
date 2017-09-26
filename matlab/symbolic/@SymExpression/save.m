function file = save(obj, file)
    % Save the symbolic expression of a wolframe MX file
    %
    %
    % Parameters:
    %   obj: the expressions other than the main object 
    %   @type SymExpression
    %   file: the (full) file name of exported file @type char
    %
    % Return values:
    %   file: the full file name of the exported function @type char
    

   
    
    assert(ischar(file),'The export destination file name must be specified explicitly.');
    
    % export directory
    [rel_path, filename] = fileparts(file);
    export_path = GetFullPath(rel_path);
        
    if ~(exist(export_path,'dir')==7)
        error(['The path to export functions does not exist: %s\n',...
            'Please ensure to create the folder, and call this function again.\n',...
            'Aborting ...\n'], export_path);
    end
    % For windows, use '/' instead of '\'. Otherwise mathematica does
    % not recognize the path.
    if ispc
        export_path = strrep(export_path, '\','/');
    end
    
    filename = [filename,'.mx'];
    
    eval_math(['Export[FileNameJoin[{' str2mathstr(export_path),',',str2mathstr(filename) '}],' obj.s '];']);
    
    
    file = fullfile(export_path,filename);  
end  
    