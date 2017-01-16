function obj = setParam(obj, varargin)
    % Sets the controller parameters
    %
    % Parameters:
    % varargin: name-value pairs of control parameters. Expected
    % arguments are:
    %  kp: kp @type double
    %  kd: kd @type double
    


    argin = struct(varargin{:});

    if isfield(argin, 'kp')
        assert(isnumeric(argin.kp) && isscalar(argin.kp) && (argin.kp > 0), ...
            ['(kp) must be a scalar positive number. \n',...
            'wrong input argument: %d'], argin.kp);
        obj.Param.kp = argin.kp;
    end
    if isfield(argin, 'kd')
        assert(isnumeric(argin.kd) && isscalar(argin.kd) && (argin.kd > 0), ...
            ['(kd) must be a scalar positive number. \n',...
            'wrong input argument: %d'], argin.kd);
        obj.Param.kd = argin.kd;
    end
    
end