function xn = calcDiscreteMap(obj, t, x, varargin)
    % calculates the discrete map of the dynamical system that maps
    % xminus from xplus. Subclasses must implement this method by its
    % own.
    %
    % @note By default, this discrete map will be a Identity map.
    % For specific discrete map, please implement as a subclass of
    % this class
    %
    % Parameters:
    % t: the time instant
    % xminus: the pre-impact states @type colvec
    %
    % Return values:
    % xplus: the post-impact states @type colvec
    
    xn = x;
    
end