function obj = addParam(obj, varargin)
    % Add parameter variables of the dynamical system
    %
    % Parameters:
    %  varargin: the name-value pairs (or struct) of the system
    %  parameters
    
    pars = struct(varargin{:});
    
    assert(all(cellfun(@(x)isa(x,'SymVariable'),struct2cell(pars))), ...
        'The parameter fields must be a SymVariable object.');
    
    obj.Params = pars;
    
end