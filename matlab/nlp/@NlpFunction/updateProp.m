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
    if isfield(argin, 'lb')
        obj =  setBoundary(obj, argin.lb, []);
    end
    
    if isfield(argin, 'ub')
        obj =  setBoundary(obj, [], argin.ub);
    end
    

    
    
    
end