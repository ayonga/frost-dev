function [indices] = getPositionOutputIndex(obj, output_name)
    % Returns the indices of the position modulating outputs of the domain
    % specified by ''output_name''.
    %
    % Parameters:
    % output_name: an array of output names @type cell
    
    if iscell(output_name) 
        indices = cellfun(@(x)getPosition(obj.ActPositionOutput, x), output_name,...
            'UniformOutput',false);
        indices = horzcat(indices{:});
    elseif ischar(output_name)
        % specified only one output
        indices = getPosition(obj.ActPositionOutput, output_name);
    end
end