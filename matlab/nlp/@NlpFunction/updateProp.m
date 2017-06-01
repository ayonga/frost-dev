function obj = updateProp(obj, varargin)
    % This function updates the properties of the class object based on the
    % input name-value pair arguments.
    %
    % Parameters:
    %  varargin: variable nama-value pair input arguments, in detail:
    %   lb: lower limit @type colvec
    %   ub: upper limit @type colvec
    %  @type rowvec
    
    argin = struct(varargin{:});
    
    % set boundary values
    if all(isfield(argin, {'ub','lb'}))
        obj =  setBoundary(obj, argin.lb, argin.ub);
    
    elseif isfield(argin, 'lb')
        obj =  setBoundary(obj, argin.lb, []);
    
    
    elseif isfield(argin, 'ub')
        obj =  setBoundary(obj, [], argin.ub);
    end
    
    if isfield(argin, 'AuxData') && ~isempty(argin.AuxData)
        obj = setAuxdata(obj, argin.AuxData);
    end
    
    if isfield(argin, 'SymFun')
        obj = setSymFun(obj, argin.SymFun);
    end
    
end