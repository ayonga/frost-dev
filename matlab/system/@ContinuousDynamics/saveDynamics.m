function obj = saveDynamics(obj, path, varargin)
    % export the symbolic expressions of the system dynamics matrices and
    % vectors and compile as MEX files.
    %
    % Parameters:
    %  export_path: the path to export the file @type char
    %  varargin: variable input parameters @type varargin
    %   StackVariable: whether to stack variables into one @type logical
    %   File: the (full) file name of exported file @type char
    %   ForceExport: force the export @type logical
    %   BuildMex: flag whether to MEX the exported file @type logical
    %   Namespace: the namespace of the function @type char
    %   NoPrompt: answer yes to all prompts
    
    saveString = ['DumpSave[','"',path,'"',','];
    saveString = [saveString,...
        eval_math('Select[Names["Global`*"], StringMatchQ[#, "symvar*"] &]')];
    saveString = [saveString,'];'];
    eval_math(saveString);
    
    return;
    
    saveString = ['DumpSave[','"',path,'"',',{',obj.Mmat.s];
    
    for i=1:length(obj.Fvec)
        saveString = [saveString,',',obj.Fvec{i}.s];
    end
    saveString = [saveString,...
        ',',obj.Gmap.Control.u.s,...
        ',',obj.States.x.s,...
        ',',obj.States.dx.s,...
        ',',obj.States.ddx.s,...
        ',',obj.Inputs.u.s,...
        '}];'];
    
    eval_math(saveString);
    
end