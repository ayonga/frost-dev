function obj = compile(obj, model, varargin)
    % Compiles the symbolic expression of kinematic functions related to
    % the domain in Mathematica
    %
    % Parameters:
    %  model: a rigid body model of type RigidBodyModel
    %  varargin: optional arguments for kinematic compile function. 
    %
    % @copydetails Kinematics::compile(obj, model, re_load)
    %
    % See also: Kinematics::compile
    
    
    
    
    % first compile symbolic expressions holonomic constraints
    compile(obj.HolonomicConstr, model, varargin{:});
    
    
    
    
    %     kin_objects = {obj.UnilateralConstr.KinGroupTable.KinObj};
    %     for i=1:length(kin_objects)
    %         if ~isa(kin_objects{i},'KinematicContact')
    %             % compile all non-contact type kinematic constraints
    %             compile(kin_objects{i}, model, varargin{:});
    %         end
    %     end
    
    
    
    % kinematic type of unilateral constraints
    kin_objects = obj.UnilateralConstr{strcmp('Kinematic',obj.UnilateralConstr.Type),'KinObject'};
    if ~isempty(kin_objects)        
        cellfun(@(x)compile(x, model, varargin{:}), kin_objects);
    end
    
end
