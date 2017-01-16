function obj = setVelocityOutput(obj, act, des)
    % Adds a velocity-modulating output of the domain
    %
    % Parameters:
    % act: the kinematic function for the velocity-modulating
    % output @type Kinemtics
    % des: the function type of the desired output @type char


    if isempty(act)
        % unset the velocity output with empty input argument
        obj.ActVelocityOutput = [];
        obj.DesVelocityOutput = [];
    else

        if getDimension(act) > 1
            error('The actual velocity output must be a scalar kinematic function');
        end
        obj.ActVelocityOutput = act;

        % reload the domain-specific naming configurations
        obj.ActVelocityOutput.Prefix = 'ya1';
        obj.ActVelocityOutput.Name = obj.Name;

        % setup desired output                
        obj.DesVelocityOutput = struct;
        obj.DesVelocityOutput.Type = des;
        obj.DesVelocityOutput.Symbols = struct(...
            'y',['$yd1["',obj.Name,'"]'],...
            'dy',['$dyd1["',obj.Name,'"]']);
        obj.DesVelocityOutput.Funcs = struct(...
            'y',['yd1_',obj.Name,],...
            'dy',['dyd1_',obj.Name]);

        % set parameter structure for velocity output
        [~,n_param] = obj.getDesOutputExpr(des);

        obj.Param.v = nan(1,n_param);
    end

end