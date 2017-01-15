function obj = setParameters(obj, varargin)
    % Sets the parameter value of the desired outputs
    %
    % Parameters:
    % varargin: name-value pairs of parameter sets. For instance,
    % ('a', a_mat). It could be also given as a structured data
    % with each field contains a set of parameters.

    params = struct(varargin{:});

    if isfield(params, 'p')
        assert(all(size(obj.Parameters.p)==size(params.p)),...
            ['The size of (p) is incorrect. \n',...
            'Expected size is: (%d, %d).'], size(obj.Parameters.p,1), size(obj.Parameters.p,2));
        obj.Parameters.p = params.p;
        fprintf('%s: The parameter (%s) is updated.\n',obj.Name, 'p');
    end

    if isfield(params, 'v')
        assert(all(size(obj.Parameters.v)==size(params.v)),...
            ['The size of (v) is incorrect. \n',...
            'Expected size is: (%d, %d).'], size(obj.Parameters.v,1), size(obj.Parameters.v,2));
        obj.Parameters.v = params.v;
        fprintf('%s: The parameter (%s) is updated.\n',obj.Name, 'v');
    end


    if isfield(params, 'a')
        assert(all(size(obj.Parameters.a)==size(params.a)),...
            ['The size of (a) is incorrect. \n',...
            'Expected size is: (%d, %d).'], size(obj.Parameters.a,1), size(obj.Parameters.a,2));
        obj.Parameters.a = params.a;
        fprintf('%s: The parameter (%s) is updated.\n',obj.Name, 'a');
    end
end