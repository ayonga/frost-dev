function obj = setResetMap(obj, model, rigid_impact, relabel_matrix, reset_point)
    % Sets the reset map for the current domain.
    %
    %
    % Parameters:
    % model: a rigid body model of type RigidBodyModel
    % rigid_impact: indicates whether it goes through a rigid impact
    % @type logical
    % relabel_matrix: coordinate relabelling matrix @type matrix
    % reset_point: a point to be reset to the origin (0,0,0) @type KinematicContact
    %
    % @note The reset point can be specified as a struct with the following
    % required fields:
    % - ParentLink
    % - Offset
    
    if isempty(obj.ResetMap) || ~isstruct(obj.ResetMap)
        obj.ResetMap = struct;
    end
        
    if nargin > 2
        assert(islogical(rigid_impact),'The third argument must be a logical variable');
        obj.ResetMap.RigidImpact = rigid_impact;
    end
    
    
    if nargin > 3
        
        
        % validate input argument
        assert(all(size(relabel_matrix) == [model.nDof, model.nDof]),...
            'The coordinate relabelling matrix must be a square matrix with dimension: %d\n',...
            model.nDof);
        
        % set coordinate relabel matrix
        obj.ResetMap.RelabelMatrix = relabel_matrix;
    end
    
    if nargin > 4
        % construct a reset point object (KinematicContact)
        if isstruct(reset_point)
            reset_point.ModelType = model.Type;
            reset_point.ContactType = 'PointContactWithFriction';
            reset_point.Name = obj.Name;
            reset_point.Prefix = 'p';
            obj.ResetMap.ResetPoint = KinematicContact(reset_point);
            
        elseif isa(reset_point, 'KinematicContact')
            reset_point.ModelType = model.Type;
            reset_point.ContactType = 'PointContactWithFriction';
            obj.ResetMap.ResetPoint = reset_point;
            obj.ResetMap.ResetPoint.Name = obj.Name;
            obj.ResetMap.ResetPoint.Prefix = 'p';
            
        end
    end
    
    
    
    
end
