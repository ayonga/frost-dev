function obj = setOption(obj, varargin)
    % Sets the object options, and return the complete list of option
    % structure including unchanged default options.
    %
    % Parameters:
    % varargin: name-value pairs of option field value
    %
    % Return values:
    % options: the complete list of final option structure
    
    new_opts = struct(varargin{:});
    
    obj.Options = struct_overlay(obj.Options, new_opts,{'AllowNew',true});
    
    
end