function [status] = build_mex(build_dir, src_files, varargin)
    % Compile C/C++ files to Matlab MEX files for Windows, MacOS and Linux
    % (Tested on Ubuntu 14.04).
    %
    % Parameters:
    %  build_dir: the directory name of the folder where the source functions are
    %  located. It will be also used as the build directory for MEX files.
    %  @type char
    %  src_files: the list of file names that need to be compiled. @type
    %  cellstr 
    %  varargin: extra MEX build options @type varargin
    %
    % @author Wen-Loong Ma <wenloong.ma@gmail.com>
    % @author Ayonga Hereid
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    
    
    %| @note Specify ''CC'' to the supported version of compiler to get rid
    %of the annoying warnings.
    CC = '/usr/bin/g++-4.9';
    
    % get the default MEX extension of the current OS
    mex_ext = mexext();
    
    % check the directory exists
    if ~(exist(build_dir, 'dir'))
        fprintf('The build directory does not exist: %s\n', build_dir);
        fprintf('Aborting ...\n');
        status = false;
        return;
    end
    
    if ischar(src_files)
        % convert to a cell
        src_files = {src_files};
    end
    num_files = length(src_files);
    
    % parpool(4)
    
    for i = 1 : num_files
        
        src_file_full_path = fullfile(build_dir,normalize(src_files{i},'.cc'));
        
        src_file = dir(src_file_full_path);
        if isempty(src_file)
            fprintf('File not found: %s\n', src_files{i});
            continue;
        end
        
        % check if an already compiled MEX file exists
        if exist(fullfile(build_dir,[src_files{i},'.',mex_ext]), 'file')
            mexFile = dir(fullfile(build_dir,[src_files{i},'.',mex_ext]));
            mexDate = datetime(mexFile.datenum,'ConvertFrom','datenum');
            srcData = datetime(src_file.datenum,'ConvertFrom','datenum');
            
            % abort build process if the MEX file is newer than the source file
            if mexDate > srcData
                fprintf('This file has been already compiled: %s\n', src_files{i});
                continue;
            end
       
        end
        
        fprintf('Compiling: %s.cc\t', src_files{i});
        tic
        mex(...
            '-g', ...
            '-outdir', build_dir, ...
            ['GCC=',CC],...
            '-silent',...
            varargin{:}, ...
            src_file_full_path ...
            );
        toc
        %         disp(['%s.mex  ', src_files{i}]);
    end
    
    
    %     delete('*.pdb');
    %     delete('*.lib');
    
    
end


function file = normalize(file,ext)
    [~,~,x] = fileparts(file);
    if isempty(x)
        file = [file ext];
    end
end





