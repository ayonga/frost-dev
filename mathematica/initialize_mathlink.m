function initialize_mathlink()
    % setup Wolfram Mathematica MathLink environment
    
     
    
    cur = fileparts(mfilename('fullpath'));
    
    math('$Version')
    
    math_app_path = fullfile(cur,'Applications');
    
    if ispc
        % For windows, use ''/' instead of '\'. Otherwise mathematica does
        % not recognize the path.
        math_app_path = strrep(math_app_path,'\','/');
    end
    math('SetOptions[ToString, PageWidth->Infinity];');
    
    
    math(['$Path=DeleteDuplicates[Append[$Path,',str2mathstr(math_app_path),']];']);
    
    math('Needs["ExtraUtils`"]');
    
    eval_math('Needs["RobotManipulator`"];');
end
