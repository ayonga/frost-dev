function [tn, varargout] = calcDiscreteMap(obj, t, states)
    % calculates the discrete map of the dynamical system that maps
    % xminus from xplus. Subclasses must implement this method by its
    % own.
    %
    % @note By default, this discrete map will be a Identity map.
    % For specific discrete map, please implement as a subclass of
    % this class
    %
    % Parameters:
    % t: the time instant @type double
    % x (repeatable): the pre-impact states @type colvec
    %
    % Return values:    
    % tn: the time after reset @type double
    % xn: the post-impact states @type colvec
    arguments
        obj DiscreteDynamics
        t double {mustBeNonnegative}
    end
    arguments (Repeating)
        states double
    end
    
    tn = t;
    varargout = states;
    
end