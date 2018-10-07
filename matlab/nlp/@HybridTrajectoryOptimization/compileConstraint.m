function compileConstraint(obj, phase, constr, export_path, exclude, varargin)
    % Compile and export symbolic expression and derivatives of all NLP functions
    %
    % @note If 'phase' is empty, then it will compile all phases.
    % @note If 'constr' is emtpy, then it will compile all constraints.
    %
    % Parameters:
    %  phase: the phase Nlp @type integer
    %  constr: a list of constraints to be compiled @type cellstr
    %  export_path: the path to export the file @type char
    %  exclude: a list of functions to be excluded @type cellstr
    %  varargin: variable input parameters @type varargin
    %   StackVariable: whether to stack variables into one @type logical
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type string
    
    if nargin < 5
        exclude = {};
    end
    
    
    if isempty(phase)
        phase = 1:1:numel(obj.Phase);
    elseif ischar(phase)
        phase = getPhaseIndex(obj,phase);
    elseif iscell(phase)
        phase = getPhaseIndex(obj,phase{:});
    end


    for k=phase
        compileConstraint(obj.Phase(k), constr, export_path, exclude, varargin{:});
    end
    
   
end