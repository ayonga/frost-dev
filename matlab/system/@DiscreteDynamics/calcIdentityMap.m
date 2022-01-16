function [tn, xn] = calcIdentityMap(obj, t, x)
    % calculates the discrete map of the dynamical system that maps
    % xminus from xplus. Subclasses must implement this method by its
    % own.
    %
    % @note By default, this discrete map will be a Identity map.
    % For specific discrete map, please implement as a subclass of
    % this class
    
    
    tn = t;
    xn = x;
    
end