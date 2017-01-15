function status = export(obj, export_path, do_build)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files.
    %
    % Parameters:
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    %  do_build: determine whether build the mex files.
    %  @type logical  @default true
    %
    % Return values:
    % status: indicator of successful export/built process @type logical
    
    if nargin < 3
        do_build = true;
    end
    
    status = false;
    
    % export holonomic constraints
    export(obj.HolonomicConstr, export_path, do_build);
    
   
    
    % kinematic type of unilateral constraints
    kin_objects = obj.UnilateralConstr{strcmp('Kinematic',obj.UnilateralConstr.Type),'KinObject'};
    if ~isempty(kin_objects)        
        cellfun(@(x)export(x, export_path, do_build), kin_objects);
    end
    
    
end
