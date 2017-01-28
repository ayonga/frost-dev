function [indices] = getHolonomicConstrIndex(obj, constr)
    % Returns the indices of the position modulating outputs of the domain
    % specified by ''output_name''.
    %
    % Parameters:
    % output_name: an array of output names @type cell
    
    if iscell(constr) 
        indices = cellfun(@(x)getPosition(obj.HolonomicConstr, x), constr,...
            'UniformOutput',false);
        indices = horzcat(indices{:});
    elseif ischar(constr)
        % specified only one output
        indices = getPosition(obj.HolonomicConstr, constr);
    end
end