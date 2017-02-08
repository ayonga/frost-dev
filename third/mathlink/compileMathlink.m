function [] = compileMathlink()
% This is to compile mathlink to *.mex* files
% Note: the math.c has not been updated since 2004, thus there is no point
% for you to compile it yourself. 
% We recommend you to use the compiled *.mex* files included.


Mathematica_path = '/usr/local/Wolfram/Mathematica/11.0/SystemFiles/';

mex(['-I', Mathematica_path, 'Links/MathLink/DeveloperKit/Linux-x86-64/CompilerAdditions/'], ...
    ['-L', Mathematica_path, 'Links/MathLink/DeveloperKit/Linux-x86-64/CompilerAdditions/'], ...
    '-lML64i3', ...
    ['-I', Mathematica_path, 'IncludeFiles/C'], ...
    'math.c');

% Remove the ~ files if there are any.
delete('*.*~'); 

end
