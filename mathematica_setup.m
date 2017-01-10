function mathematica_setup()
    % setup Wolfram Mathematica environment
    
    cur = fileparts(mfilename('fullpath'));
    
    
    math_app_path = fullfile(cur, 'mathematica','Applications');
    
    math('$Version')
    
    math('SetOptions[ToString, PageWidth->Infinity];');
    
    math(['$Path=DeleteDuplicates[Append[$Path,"',math_app_path,'"]];']);
    
    math('Needs["ExtraUtils`"]');
end
