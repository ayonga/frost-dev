function obj = addPositionOutput(obj, act, des)
    % Adds position-modulating outputs of the domain
    %
    % Parameters:
    % act: the kinematic function for the actual position-modulating
    % output @type Kinemtics
    % des: the function type of the desired output @type char

    if iscell(act)
        % validate dependent arguments
        check_dimension = @(x) getDimension(x)>1;

        if any(cellfun(check_dimension,act))
            error('The actual output must be a scalar kinematic function');
        end
    elseif isa(act, 'Kinematics')
        if getDimension(act) ~= 1
            error('The actual output must be a scalar kinematic function');
        end
    else
        error('The actual output must be Kinematics objects.');
    end

    % initialize the actual output object
    if isempty(obj.ActPositionOutput)
        obj.ActPositionOutput  = ...
            KinematicGroup('Name', obj.Name, 'Prefix', 'ya2');
    end

    obj.ActPositionOutput = addKinematic(obj.ActPositionOutput, act);
    % setup the desired output parameter structure
    [~,n_param] = obj.getDesOutputExpr(des);
    n_output = getDimension(obj.ActPositionOutput);
    obj.Param.a = nan(n_output,n_param);
    
    if ~isempty(obj.DesPositionOutput)
        assert(strcmp(obj.DesPositionOutput, des), ...
            'The input desired output type does not match the current desired output type.');
    else
        % setup the desired output structure
        obj.DesPositionOutput = struct;
        obj.DesPositionOutput.Type = des;
        obj.DesPositionOutput.NumParam = n_param;
        obj.DesPositionOutput.Symbols = struct(...
            'y',['$yd2["',obj.Name,'"]'],...
            'dy',['$dyd2["',obj.Name,'"]'],...
            'ddy',['$ddyd2["',obj.Name,'"]']);
        obj.DesPositionOutput.Funcs = struct(...
            'y',['yd2_',obj.Name,],...
            'dy',['dyd2_',obj.Name],...
            'ddy',['ddyd2_',obj.Name]);

    end

     

end