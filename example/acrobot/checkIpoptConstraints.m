function [y,cl,cu] = checkIpoptConstraints(x, constraint)
    % nested function that commputes the constraints of the NLP problem
    %
    % Parameters:
    %  constraint: a structure of arrays that contains the information
    %  of all constraints
    
    cl = vertcat(constraint.LowerBound);
    cu = vertcat(constraint.UpperBound);
    % preallocation
    y   = zeros(constraint.Dimension,1);
    for i = 1:constraint.numFuncs
        var = cellfun(@(v)x(v(:)),constraint.DepIndices{i},'UniformOutput',false); % dependent variables
        
        % calculate constraints
        if isempty(constraint.AuxData{i})
            y(constraint.FuncIndices{i}) = y(constraint.FuncIndices{i}) + feval(constraint.Funcs{i}, var{:});
        else
            y(constraint.FuncIndices{i})  = y(constraint.FuncIndices{i}) + feval(constraint.Funcs{i}, var{:}, constraint.AuxData{i}{:});
        end
    end
    
    
    
end