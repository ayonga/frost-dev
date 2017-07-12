function Compile(nlp, export_path, compile_cstr, exclude)
    
    if nargin < 3
        compile_cstr = [];
    end
    if nargin < 4
        exclude = [];
    end
    if isa(nlp,'TrajectoryOptimization')
        compileConstraint(nlp,compile_cstr,export_path,exclude);
        compileObjective(nlp,[],export_path);
    elseif isa(nlp,'HybridTrajectoryOptimization')
        compileConstraint(nlp,[],compile_cstr,export_path,exclude);
        compileObjective(nlp,[],[],export_path);
    end

end