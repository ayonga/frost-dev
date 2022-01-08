function obj = appendDriftVector(obj, Fvec)
    % Append additional vf to the drift vector field Fvec(x) or Fvec(x,dx) of the
    % system
    %
    % Parameters:
    %  vf: the f(x) @type cell
    
    
    arguments
        obj
    end
    arguments (Repeating)
        Fvec SymFunction {ContinuousDynamics.validateDriftVector(obj, Fvec)}
    end
    
    
    obj.Fvec = [obj.Fvec; Fvec];
    obj.FvecName_ = [obj.FvecName_; cellfun(@(f)f.Name, Fvec,'UniformOutput',false)];

end