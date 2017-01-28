function obj = compile(obj, model, varargin)
    % Compiles the symbolic expression of kinematic functions related to
    % the guard in Mathematica
    %
    % Parameters:
    %  model: a rigid body model of type RigidBodyModel
    %  varargin: optional arguments for kinematic compile function. 
    %
    % @copydetails Kinematics::compile(obj, model, re_load)
    %
    % See also: Kinematics::compile
    
    
    
    % if reset point option is non-empty
    if ~isempty(obj.ResetMap.ResetPoint)
        compile(obj.ResetMap.ResetPoint, model, varargin{:});
    end
    
    
    
end
