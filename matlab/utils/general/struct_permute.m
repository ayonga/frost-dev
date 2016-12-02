%> @brief struct_permute Generate a set of full factorial permutations
%> based on arguments given as fields in a structure.
%> Meant to be used stand-alone or in conjunction with struct_overlay()
%> @note Derived from optPermute() on Mathworks
%> @author Eric Cousineau <eacousineau@gmail.com>
%> @example ???
%>
%> 	opt_values = struct('mass', {{5, 10, 15}}, 'pos', {{1, 2}}, 'extra',
%> 	struct('x', {{2, 3}}));
%> 	opt_set = struct_permute(opt_values);
function [opt_set] = struct_permute(opt_values)
	opt_set = {};
	
	%Test overlay?
	
	% Full factorial experiment
	fields = fieldnames(opt_values);
	nfields = length(fields);
	
	% Start recursion
	opt_blank = struct();
	do_recursion(opt_blank, 1);
	
	function do_recursion(opt, index)
		if index <= nfields
			field = fields{index};
			value = opt_values.(field);
			if iscell(value)
				% Loop through, concatenate
				for i = 1:length(value)
					opt.(field) = value{i};
					% Recurse through the rest of the options
					do_recursion(opt, index + 1);
				end
			elseif isstruct(value)
				% Recurse with a new set of options for that given option...
				% Get the set of options for that set
				% Incorporate these into permutations
				opt_subset = struct_permute(value);
				% And like normal
				for i = 1:length(opt_subset)
					opt.(field) = opt_subset{i};
					% And so on
					do_recursion(opt, index + 1);
				end
			end
		else
			% End of permute
			% Add final options to the list of permutations
			opt_set{end + 1} = opt;
		end
	end
end
