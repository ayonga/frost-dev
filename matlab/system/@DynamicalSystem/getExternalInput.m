function inputs = getExternalInput(obj, label, varargin)
    % Returns the external input defined on the dynamical system. 
    %
    % Needs to be implemented by the subclass if there is a particular
    % external inputs defined.
    
    inputs = zeros(size(obj.inputs_.External.(label)));
    warning('This method must be overloaded by the subclass. \n Default inputs: %d', inputs);
    
end