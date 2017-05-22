function obj = setLimit(obj, varargin)
    % set the physical limits of the rigid joints
    %
    % Parameters:
    % varargin: varaiable input arguments. In detail:
    %  effort: the actuation effort @type double
    %  lower: the lower bound of the joint displacement @type double 
    %  upper: the upper bound of the joint displacement @type double 
    %  velocity: the absolute bound of the joint velocity @type double
    
    %     assert(isstruct(limit),...
    %         'Expected a struct input. Instead the input argument is a %s object', class(limit));
    %
    %     assert(all(isfield(limit,{'effort','lower','upper','velocity'})),...
    %         'The input struct should have the following fields: \n %s',implode({'effort','lower','upper','velocity'},', '));
    
    
    ip = inputParser;
    ip.addParameter('effort',[],@(x)validateattributes(x,{'double'},{'scalar','real','nonnegative'}));
    ip.addParameter('lower',[],@(x)validateattributes(x,{'double'},{'scalar','real'}));
    ip.addParameter('upper',[],@(x)validateattributes(x,{'double'},{'scalar','real'}));
    ip.addParameter('velocity',[],@(x)validateattributes(x,{'double'},{'scalar','real','nonnegative'}));
    ip.parse(varargin{:});
    
    limit = ip.Results;
    
    if isempty(obj.Limit)
        obj.Limit = struct('effort',[],'lower',[],'upper',[],'velocity',[]);
    end
    fields = fieldnames(obj.Limit);
    for i=1:length(fields)
        if ~isempty(limit.(fields{i}))
            obj.Limit.(fields{i}) = ip.Results.(fields{i});
        end
    end
    
end