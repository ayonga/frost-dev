function obj = setSymFun(obj, symfun)
    % This function specify the symbolic expression (SymNlpFunction) of the
    % NLP function.
    %
    % Parameters:
    % symfun: the symbolic function object @type SymNlpFunction
    
    
    
    assert(isa(symfun,'SymNlpFunction'),...
        'The second input argument must be a SymNlpFunction object.');
    
    
    
    

    if ~isempty(obj.Dimension)
        assert(obj.Dimension == length(symfun.Expr),...
            'The dimension of the symbolic expression (%d) does not match the dimension of the NLP function (%d).\n',obj.Dimension, length(symfun.Expr));
    else
        obj.Dimension = length(symfun.Expr);
    end
    
    
    if ~isempty(obj.DepVariables)
        nvar1 = length(symfun.Vars);
        nvar2 = sum(cellfun(@(x)x.Dimension, obj.DepVariables));
        
        assert(nvar1 == nvar2,...
            'The dimensions of the dependent variables do not match.');
    end

    
    if ~isempty(obj.AuxData)
        nvar1 = length(symfun.Params);
        nvar2 = numel(obj.AuxData);
        
        assert(nvar1 == nvar2,...
            'The dimensions of the constant parameters do not match.');
    end
    
    
    obj.SymFun = symfun;
    
    obj = setFuncs(obj, symfun.Funcs);
end