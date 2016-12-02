function [status] = build_mex(build_dir, src_files, varargin)
    % Compile C/C++ files to Matlab MEX files for Windows, MacOS and Linux
    % (Tested on Ubuntu 14.04).
    %
    % Parameters:
    %  path: the directory name of the folder where the source functions are
    %  located. It will be also used as the build directory for MEX files.
    %  @type char
    %  f_list: the list of file names that need to be compiled. @type
    %  cellstr 
    %  varargin: extra MEX build options @type varargin
    %
    % @author Wen-Loong Ma <wenloong.ma@gmail.com>
    % @author Ayonga Hereid
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    
    
   
    
    
    % get the default MEX extension of the current OS
    mex_ext = mexext();
    
    % check the directory exists
    if ~(exist(build_dir, 'dir'))
        fprintf('The build directory does not exist: %s\n', build_dir);
        fprintf('Aborting ...\n');
        status = false;
        return;
    end
    
    num_files = numel(src_files);
    
    % parpool(4)
    tic
    for i = 1 : num_files
        
        src_file_full_path = fullfile(build_dir,[src_files{i},'.cc']);
        
        src_file = dir(src_file_full_path);
        if isempty(src_file)
            disp(['i = ', num2str(i), ', File not found: ', src_files{i}]);
            continue;
        end
        
        % check if an already compiled MEX file exists
        if exist(fullfile(build_dir,[src_files{i},'.',mex_ext]), 'file')
            mexFile = dir(fullfile(build_dir,[src_files{i},'.',mex_ext]));
            mexDate = datetime(mexFile.date);
            srcData = datetime(src_file.date);
            
            % abort build process if the MEX file is newer than the source file
            if mexDate > srcData
                disp(['i = ', num2str(i), ', Already Compiled: ', src_files{i}]);
                continue;
            end
       
        end
        
        disp(['i = ', num2str(i), ', Start compiling: ', src_files{i}]);
        
        mex(...
            '-g', ...
            '-outdir', build_dir, ...
            varargin{:}, ...
            src_file_full_path ...
            );
        
        disp(['i = ', num2str(i), ', Done compiling: ', src_files{i}]);
    end
    toc
    
    %     delete('*.pdb');
    %     delete('*.lib');
    
    
end









