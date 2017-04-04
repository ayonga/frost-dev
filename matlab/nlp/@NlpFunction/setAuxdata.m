function obj = setAuxdata(obj, auxdata)
    % Sets the auxilary input argument data to call the NLP function. These
    % auxilary data must be a vector of numeric values.
    %
    % Parameters:
    % auxdata: a set of auxilary input argument @type rowvec
    
    assert(isvector(auxdata) && isnumeric(auxdata), ...
        'The auxilary input argument must be a vector of numeric values.');
    
    if ~isempty(obj.SymFun)
        params = cellfun(@(x)flatten(x), obj.SymFun.Params,'UniformOutput',false);        
        nvar1 = length([params{:}]);
        nvar2 = numel(auxdata);
        
        assert(nvar1 == nvar2,...
            'The dimensions of the constant parameters do not match.');
    end
    
    obj.AuxData = auxdata;
    
    
end