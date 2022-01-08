function obj = configure(obj, bounds, varargin)
    % configure the trajectory optimizatino NLP problem
    %
    % This process will add NLP variables based on the information of the
    % dynamical system object, impose dynamical and collocation
    % constraints, then call the system constraints callback function to
    % add any system-specific constraints.
    %
    % Parameters:
    % bounds: a struct data contains the boundary values @type struct
    
    % configure NLP decision variables
    obj = obj.configureVariables(bounds);
        
    % configure NLP constraints
    obj = configureConstraints(obj, bounds, varargin{:});
end