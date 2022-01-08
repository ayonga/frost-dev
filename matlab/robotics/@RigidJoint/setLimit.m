function obj = setLimit(obj, param)
    % set the physical limits of the rigid joints
    %
    % Parameters:
    % param: name-value pair input arguments. In detail:
    %  effort: the actuation effort @type double
    %  lower: the lower bound of the joint displacement @type double 
    %  upper: the upper bound of the joint displacement @type double 
    %  velocity: the absolute bound of the joint velocity @type double
    
    %     assert(isstruct(limit),...
    %         'Expected a struct input. Instead the input argument is a %s object', class(limit));
    %
    %     assert(all(isfield(limit,{'effort','lower','upper','velocity'})),...
    %         'The input struct should have the following fields: \n %s',implode({'effort','lower','upper','velocity'},', '));
    
    arguments
        obj
        param.effort double {mustBeScalarOrEmpty,mustBeReal,mustBeNonnegative} 
        param.lower double {mustBeScalarOrEmpty,mustBeReal,mustBeNonNan} 
        param.upper double {mustBeScalarOrEmpty,mustBeReal,mustBeNonNan} 
        param.velocity double {mustBeScalarOrEmpty,mustBeReal,mustBeNonnegative} 
    end
    
    
    if isempty(obj.Limit)
        obj.Limit = struct('effort',[],'lower',[],'upper',[],'velocity',[]);
    end
    fields = fieldnames(obj.Limit);
    for i=1:length(fields)
        if isfield(param, fields{i})
            obj.Limit.(fields{i}) = param.(fields{i});
        end
    end
    
end