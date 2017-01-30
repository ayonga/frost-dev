function initialize_mathlink()
    % setup Wolfram Mathematica environment
    
    % try
    %     math('$Version')
    % catch
    %     % get mathematica version
    %     [~, ver] = system('mathematica --version');
    %
    %     % determine mathlink library path
    %     if ismac
    %         % Code to run on Mac plaform
    %     elseif isunix
    %         % Code to run on Linux plaform
    %         mathematica_installation_dir = '/usr/local/Wolfram/Mathematica/';
    %         mathlink_sub_dir = '/SystemFiles/Links/MathLink/DeveloperKit/Linux-x86-64/CompilerAdditions';
    %         mathlink_lib_dir = [mathematica_installation_dir,ver(1:end-1),mathlink_sub_dir];
    %     elseif ispc
    %         % Code to run on Windows platform
    %     else
    %         disp('Platform not supported')
    %     end
    %
    %     % set ld_library_path
    %     system(['LD_LIBRARY_PATH=',mathlink_lib_dir,':$LD_LIBRARY_PATH']);
    %     system('export LD_LIBRARY_PATH');
    %
    %
    %     math('$Version')
    % end
    
    
    cur = fileparts(mfilename('fullpath'));
    
    math('$Version')
    
    math_app_path = fullfile(cur, 'mathematica','Applications');
    
    
    math('SetOptions[ToString, PageWidth->Infinity];');
    
    math(['$Path=DeleteDuplicates[Append[$Path,"',math_app_path,'"]];']);
    
    math('Needs["ExtraUtils`"]');
end
