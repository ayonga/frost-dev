function obj = exportLineFunctions(obj, export_path, do_build)
    % This function compile the symbolic expressions of the animation
    % objects (kinematic) position and first order Jacobian.
    %
    % @attention initialize(obj) must be called before run this function.
    
    if nargin < 3
        do_build = true;
    end
    
    initialize(obj, true);
    
    if ~isempty(obj.LineObjects)
        n_line = length(obj.LineObjects);
        for i=1:n_line
            compile(obj.LineObjects(i).Kin, obj, true);
            export(obj.LineObjects(i).Kin, export_path, do_build);
        end
    end
end
