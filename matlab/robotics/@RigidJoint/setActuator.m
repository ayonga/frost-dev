function obj = setActuator(obj, varargin)
    % set the physical limits of the rigid joints
    %
    % Parameters:
    % varargin: varaiable input arguments. In detail:
    %  Inertia: the inertia of the actuator (before gear box) @type double
    %  Ratio: the deceleration ratio of the gear box @type double 
    
    % set the actuator to empty (remove actuation) if no argument is
    % detected
    if nargin == 1
        obj.Actuator = [];
        return;
    end
    
    ip = inputParser;
    ip.addParameter('Inertia',[],@(x)validateattributes(x,{'double'},{'scalar','real','finite','nonnegative'}));
    ip.addParameter('Ratio',[],@(x)validateattributes(x,{'double'},{'scalar','real','finite','positive'}));
    ip.parse(varargin{:});
    
    if isempty(obj.Actuator)
        obj.Actuator = struct('Inertia',[],'Ratio',[]);
    end
    
    
    if ~isempty(ip.Results.Inertia)
        obj.Actuator.Inertia = ip.Results.Inertia;
    end
    
    if ~isempty(ip.Results.Ratio)
        obj.Actuator.Ratio = ip.Results.Ratio;
    end
    
end