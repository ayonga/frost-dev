% INSERT-SNIPPET
%   Insert a piece of code in the Matlab editor.
%   User Manual:
%     1. Copy the code of this file.
%     2. Create a new shortcut in Matlab (right click on the Shortcut toolbar > New Shortcut).
%     3. Paste the code into 'Callback'.
%     4. Change the code in the 22th line.
%     5. Give a name to your shortcut in 'Label'.
%     6. Click 'Save'.
%     7. Click on the newly created shortcut to paste your code into the editor.
%   Tested with Matlab R2010a, R2013a.
%
% Inspired from http://blogs.mathworks.com/community/2011/05/16/matlab-editor-api-examples/
%
% 10-May-2013, Revised 10-May-2013, Revised 23-August-2013, Revised 12-November-2014
% Comments and questions to: vincent.mazet@unistra.fr.

if exist('snippet'), snippet = struct('snippet',snippet); end;      % Save the variable SNIPPET, if it exists

% Type your text here!
snippet.txt = ...
[ '% ceci est un commentaire\n' ...
  'plot(0:2*pi, sin(0:2*pi), ''Color'', ''r'');' ];
 
snippet.txt = strrep(snippet.txt, '\n', sprintf('%c',10));          % Replace '\n' by a new line
if verLessThan('matlab', '8.1.0')
    snippet.activeEditor = editorservices.getActive;                % Get the active document in the editor
else
    snippet.activeEditor = matlab.desktop.editor.getActive;         % Get the active document in the editor
end
snippet.activeEditor.JavaEditor.insertTextAtCaret(snippet.txt);     % Insert text at the current position
if isfield(snippet,'snippet')                                       % Delete SNIPPET (or replace it by its original value)
    snippet = snippet.snippet;
else
    clear snippet
end;
