function obj = setSymFun(obj, symfun)
    % This function specify the symbolic expression (SymFunction) of the
    % NLP function.
    %
    % Parameters:
    % symfun: the symbolic function object @type SymFunction
    
    
    
    assert(isa(symfun,'SymFunction'),...
        'The second input argument must be a SymFunction object.');
    
    
    obj.setName(symfun.Name);
        
    

    if ~isempty(obj.Dimension) && obj.Dimension~=0
        assert(obj.Dimension == length(symfun),...
            'The dimension of the symbolic expression (%d) does not match the dimension of the NLP function (%d).\n',obj.Dimension, length(symfun));
    else
        obj.Dimension = length(symfun);
    end
    
    
    if ~isempty(obj.DepVariables)
        vars = cellfun(@(x)flatten(x), symfun.Vars,'UniformOutput',false);        
        nvar1 = length([vars{:}]);
        nvar2 = sum([obj.DepVariables.Dimension]);
        
        assert(nvar1 == nvar2,...
            'The dimensions of the dependent variables do not match.');
    end

    
    if ~isempty(obj.AuxData)
        params = cellfun(@(x)flatten(x), symfun.Params,'UniformOutput',false);        
        nvar1 = length([params{:}]);
        nvar2 = numel(obj.AuxData);
        
        assert(nvar1 == nvar2,...
            'The dimensions of the constant parameters do not match.');
    end
    
    
    obj.SymFun = symfun;
    
    funcs = symfun.Funcs;
    funcs.Func = symfun.Name;
    
    obj = setFuncs(obj, funcs);
end
