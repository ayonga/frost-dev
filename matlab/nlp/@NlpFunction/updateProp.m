function obj = updateProp(obj, varargin)
    % This function updates the properties of the class object based on the
    % input name-value pair arguments.
    %
    % Parameters:
    %  varargin: variable nama-value pair input arguments, in detail:
    %   Dimension: dimension of the variable @type integer
    %   lb: lower limit @type colvec
    %   ub: upper limit @type colvec
    %   Type: the type of the function @type char
    %   AuxData: a row vector of constant arguments of the function.
    %  @type rowvec
    
    argin = struct(varargin{:});
    
    
    
    % set the dimension to be 1 by default
    if isfield(argin, 'Dimension')
        obj = setDimension(obj, argin.Dimension);
    end
    
    % set boundary values
    if isfield(argin, 'lb')
        obj =  setBoundary(obj, argin.lb, []);
    end
    
    if isfield(argin, 'ub')
        obj =  setBoundary(obj, [], argin.ub);
    end
    
    if isfield(argin, 'Type')
        obj = setType(obj, argin.Type);
    end

    if isfield(argin, AuxData)
        obj = setAuxdata(obj, argin.AuxData);
    end
end