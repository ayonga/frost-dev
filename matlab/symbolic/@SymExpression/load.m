function obj = load(obj, file)
    % load the saved symbolic expression from a wolframe MX file
    %
    %
    % Parameters:
    %   obj: the expressions other than the main object 
    %   @type SymExpression
    %   file: the (full) file name of exported file @type char
    %
    

   
    
    assert(ischar(file),'The export destination file name must be specified explicitly.');
    
    
    
    
    % export directory
    [rel_path, filename] = fileparts(file);
    file_path = GetFullPath(rel_path);
        
    
    % For windows, use '/' instead of '\'. Otherwise mathematica does
    % not recognize the path.
    if ispc
        file_path = strrep(file_path, '\','/');
    end
    
    filename = [filename,'.mx'];
    
    if ~(exist(fullfile(file_path,filename),'file') == 2)
        error('Unable to read file %s. No such file or directory.', fullfile(file_path,filename));
    end
    
    
    eval_math([obj.s '=Import[FileNameJoin[{' str2mathstr(file_path),',',str2mathstr(filename) '}]];']);
    
    
    
end  
    



    