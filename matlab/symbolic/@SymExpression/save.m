function file = save(obj, file_path, filename)
    % Save the symbolic expression of a wolframe MX file
    %
    %
    % Parameters:
    %   obj: the expressions other than the main object 
    %   @type SymExpression
    %   file_path: the path to export the file @type char
    %   file: the (full) file name of exported file @type char
    %
    % Return values:
    %   file: the full file name of the exported function @type char
    

   
        
    if ~(exist(file_path,'dir')==7)
        error(['The path to export functions does not exist: %s\n',...
            'Please ensure to create the folder, and call this function again.\n',...
            'Aborting ...\n'], file_path);
    end
    % For windows, use '/' instead of '\'. Otherwise mathematica does
    % not recognize the path.
    if ispc
        file_path = strrep(file_path, '\','/');
    end
    
    filename = [filename,'.mx'];
    
    eval_math(['Export[FileNameJoin[{' str2mathstr(file_path),',',str2mathstr(filename) '}],' obj.s '];']);
    
    
    file = fullfile(file_path,filename);  
    
    fprintf('The symbolic expression exported to %s.\n', file);
end  
    