%> @brief struct_overlay Overlay default fields with input fields
%> @author Eric Cousineau <eacousineau@gmail.com>
%> @note From optOverlay() on Mathworks, modified
function [opts] = struct_overlay(opts_default, opts_in, options)

    % Simple cases
    if iscell(opts_default)
        opts_default = struct(opts_default{:});
    end
    if isempty(opts_in)
        opts = opts_default;
        return;
    end
    if iscell(opts_in)
        opts_in = struct(opts_in{:});
    end

	is_valid = @(o) isstruct(o) && length(o) == 1;
	assert(is_valid(opts_default), 'opts_default must be scalar struct or structable cell array');
	assert(is_valid(opts_in), 'opts_in must be scalar struct or structable cell array');
    
    persistent func_opts_default;
    if isempty(func_opts_default)
        func_opts_default = struct('Recursive', true, 'AllowNew', false);
    end
    if nargin < 3
        options = func_opts_default;
    else
        if iscell(options)
            options = struct(options{:});
        end
        options = struct_overlay(func_opts_default, options);
    end
    
    %TODO Tackle struct arrays?
    new_fields = fieldnames(opts_in);
    options_index = find(strcmp(new_fields, 'overlay_options'));
    indices = 1:length(new_fields);
    if ~isempty(options_index)
        options = struct_overlay(options, opts_in.overlay_options);
        indices(options_index) = [];
    end
    
    if ~options.AllowNew
        % Check to see if there are bad fields
        fields = fieldnames(opts_default);
        unoriginal = setdiff(new_fields(indices), fields);
        if ~isempty(unoriginal)
            error(['Fields are not in original: ', implode(unoriginal, ', ')]);
        end
    end
    
    opts = opts_default;
    
    for i = 1:length(indices)
        index = indices(i);
        field = new_fields{index};
        new_value = opts_in.(field);
        % Apply recursion
        if options.Recursive && isfield(opts, field)
            cur_value = opts.(field);
            % Both values must be proper option structs
            if is_valid(cur_value) && is_valid(new_value) 
                new_value = struct_overlay(cur_value, new_value, options);
            end
        end
        opts.(field) = new_value;
    end
end
