clc;
clear


MATH_VER = '13.2';  %NOTE: change it to currently installed Wolfram Mathematica version

%%

if ismac      %NOTE: add `ws_comp_dir` (get below) to your DYLD_LIBRARY_PATH path
    ws_comp_dir = '/Applications/Mathematica.app/Contents/SystemFiles/Links/WSTP/DeveloperKit/MacOSX-X86-64/CompilerAdditions';
    wslib=fullfile(ws_comp_dir, 'libWSTPi4.a');


elseif isunix %NOTE: add `ws_comp_dir` (get below) to your LD_LIBRARY_PATH path
    ws_comp_dir = fullfile('/usr/local/Wolfram/Mathematica/',MATH_VER,'SystemFiles/Links/WSTP/DeveloperKit/Linux-x86-64/CompilerAdditions');
    wslib=fullfile(ws_comp_dir, 'libWSTP64i4.so');

elseif ispc %NOTE: add `ws_link_dir` (get below) and the system uses path
    ws_link_dir = fullfile('C:\Program Files\Wolfram Research\Mathematica\',MATH_VER,'\SystemFiles\Links\WSTP\DeveloperKit\Windows-x86-64\SystemAdditions\');
    ws_comp_dir = fullfile('C:\Program Files\Wolfram Research\Mathematica\',MATH_VER,'\SystemFiles\Links\WSTP\DeveloperKit\Windows-x86-64\CompilerAdditions');
    wslib=['"',fullfile(ws_comp_dir,'wstp64i4.lib'),'"'];       % windows does not recognize the space in the path
    ws_comp_dir = ['"', ws_comp_dir, '"'];                      % windows does not recognize the space in the path

    % NOTE: you also need to add the Mathematica installation directory (e.g., C:\Program Files\Wolfram Research\Mathematica\12.3) to the system user path
else
    error('architecture not supported');
end


%%

%make command
if ismac
    command=sprintf('mex -D__STDC__ -v -I%s %s %s', ws_comp_dir, 'math.cxx', wslib);
else
    command=sprintf('mex -D__STDC__ -v -I%s %s %s', ws_comp_dir, 'math.c', wslib);
end
%compile
eval(command)

%%

testscript