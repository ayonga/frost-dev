function obj = setParamValue(obj, varargin)
    % set the actual value of the system parameters
    %
    % Parameters:
    % varargin: the parameter values @type struct
    
    % convert to struct 
    params = struct(varargin{:});
    
    update_fields = intersect(fieldnames(obj.params_),fieldnames(params));
    nfields = numel(update_fields);
    if nfields > 0
        for i=1:nfields
            field = update_fields{i};
            obj.params_.(field) = params.(field);
        end
    end
    
end