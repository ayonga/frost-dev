function obj = setMassMatrix(obj, Mlist)
    % Set the mass matrix M(x) of the system
    %
    % Parameters:
    %  M:  the mass matrix M(x) @type SymFunction
    
    arguments
        obj
    end
    arguments (Repeating)
        Mlist SymFunction {ContinuousDynamics.validateMassMatrix(obj, Mlist)}
    end
    
        
    obj.Mmat = Mlist;
       
    obj.MmatName_ = cellfun(@(f)f.Name, obj.Mmat,'UniformOutput',false);
    
end
