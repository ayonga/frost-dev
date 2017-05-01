function obj = setParam(obj, varargin)
    % Sets the controller parameters
    %
    % Parameters:
    % varargin: name-value pairs of control parameters. Expected
    % arguments are:
    %  ep: epsilon for human-inspired control @type double
    %  kp: kp @type double
    %  kd: kd @type double
    %
    % @note When using ''ep'' as the control parameters, we use the
    % following relationships for ''kp'' and ''kd'': 
    % `kp = ep^2`, `kd = 2*ep`.
    %
    % @note Please do not specifiy ''ep'' and (''kp'',''kd'') at
    % the same time. In this case, only ''ep'' will be used.


    %     argin = struct(varargin{:});
    %
    %     if isfield(argin, 'ep')
    %         assert(isnumeric(argin.ep) && isscalar(argin.ep) && (argin.ep > 0), ...
    %             ['(epsilon) must be a scalar positive number. \n',...
    %             'wrong input argument: %d'], argin.ep);
    %         obj.Param.kp = argin.ep^2;
    %         obj.Param.kd = 2*argin.ep;
    %     else
    %         if isfield(argin, 'kp')
    %             assert(isnumeric(argin.kp) && isscalar(argin.kp) && (argin.kp > 0), ...
    %                 ['(kp) must be a scalar positive number. \n',...
    %                 'wrong input argument: %d'], argin.kp);
    %             obj.Param.kp = argin.kp;
    %         end
    %         if isfield(argin, 'kd')
    %             assert(isnumeric(argin.kd) && isscalar(argin.kd) && (argin.kd > 0), ...
    %                 ['(kd) must be a scalar positive number. \n',...
    %                 'wrong input argument: %d'], argin.kd);
    %             obj.Param.kd = argin.kd;
    %         end
    %     end
end