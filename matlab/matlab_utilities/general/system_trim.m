%> @brief run system command and trim leading and trailing whitespace
%> (newlines), asserting that success must be had
%> @author Eric Cousineau <eacousineau@gmail.com>
function [out] = system_trim(cmd)

[status, out] = system(cmd);
assert(status == 0, 'Error with command: %s', cmd);
out = strtrim(out);

end
