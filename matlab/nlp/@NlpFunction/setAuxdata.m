function obj = setAuxdata(obj, auxdata)
    % Sets the auxilary input argument data to call the NLP function. These
    % auxilary data must be a vector of numeric values.
    %
    % Parameters:
    % auxdata: a set of auxilary input argument @type rowvec
    
    assert(isvector(auxdata) && isnumeric(auxdata), ...
        'The auxilary input argument must be a vector of numeric values.');
    
    obj.AuxData = auxdata;
    

end