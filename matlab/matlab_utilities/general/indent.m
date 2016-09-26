%> @brief Split 'str_in' into lines and prefix each line with 'prefix'
%> @author Eric Cousineau <eacousineau@gmail.com>, AMBER Lab, under Dr.
%> Aaron Ames
function [str] = indent(str_in, prefix)
% Using sprintf for sprintf:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/249016
lines = strsplit(sprintf(str_in), sprintf('\n'));
str = sprintf([prefix, strjoin(lines, ['\n', prefix])]);
end
