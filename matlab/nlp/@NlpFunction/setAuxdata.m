function obj = setAuxdata(obj, auxdata)
    % Sets the auxilary input argument data to call the NLP function. These
    % auxilary data must be a vector of numeric values.
    %
    % Parameters:
    % auxdata: a set of auxilary input argument @type rowvec
    
    if ~iscell(auxdata), auxdata = {auxdata}; end
    
    
    
    if  isa(obj.SymFun,'SymFunction')
        
        assert(numel(auxdata) == numel(obj.SymFun.Params),...
            'The number of the constant parameters does not match.');
        
        nvar1 = cellfun(@(x)length(flatten(x)), obj.SymFun.Params);        
        nvar2 = cellfun(@(x)numel(x), auxdata); 
        
        for i=1:numel(auxdata)
            
            assert(nvar1(i) == nvar2(i),...
                'The dimension of the %d-th parameter does not match.',i);
        end
    end
    
    obj.AuxData = auxdata;
    
    
end