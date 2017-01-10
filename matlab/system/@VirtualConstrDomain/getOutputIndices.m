function [indices] = getOutputIndices(obj, output_name)
    % getJointIndices - return indices of joints specified by joints name
    % in the input 'joint_name'
    outputs = obj.outputs.actual.degreeTwoOutput;
    if iscell(output_name) 
        % when specified more than one joints
        N = numel(output_name);
        
        indices = zeros(1,N);
        
        for i=1:N
            index = find(strcmpi(outputs,output_name{i}));
            if ~isempty(index)
                indices(i) = index;
            end
        end
    elseif ischar(output_name)
        % specified only one joint
        indices = find(strcmpi(outputs,output_name));
    else
        error('please provide correct information (Joint Name)');
    end
end