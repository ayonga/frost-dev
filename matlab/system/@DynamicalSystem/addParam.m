function obj = addParam(obj, varargin)
    % Add parameter variables of the dynamical system
    %
    % Parameters:
    %  varargin: the name-value pairs (or struct) of the system
    %  parameters
    
    params = struct(varargin{:});
    
    assert(all(cellfun(@(x)isa(x,'SymVariable'),struct2cell(params))), ...
        'The parameter fields must be a SymVariable object.');
    
    new_params = fieldnames(params);
    
    for i=1:length(new_params)
        new_param = new_params{i};
        
        assert(isempty(regexp(new_param, '\W', 'once')) || ~isempty(regexp(new_param, '\$', 'once')),...
            'Invalid symbol string, can NOT contain special characters.');
        
        assert(isempty(regexp(new_param, '_', 'once')),...
            'Invalid symbol string, can NOT contain ''_''.');
        
        assert(~isempty(regexp(new_param, '^[a-z]\w*', 'match')),...
            'First letter must be lowercase character.');
                    
        if isfield(obj.Params, new_param)
            error('The parameter (%s) has been already defined.\n',new_param);
        else
            obj.Params.(new_param) = params.(new_param);
            obj.params_.(new_param) = nan(size(params.(new_param)));
        end
    end
end