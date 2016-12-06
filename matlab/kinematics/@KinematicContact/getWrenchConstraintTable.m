function conditions = getWrenchConstraintTable(obj, model, varargin)
    % Returns all admissible conditions of contact wrenches 
    %
    % 
    % Return values:
    % cond_tab: admissible conditions of type table
    
    
    n_axis_index = find(strcmp(obj.NormalAxis,{'x','y','z'})); % normal axis index
    
    c_indices = obj.cIndex;
    model_type = model.Type;
    
    switch obj.ContactType
        case 'PointContactWithFriction'
            % normal force (1), friction cone (4)
            mu = varargin{1}; % friction coefficient
            Names = categorical({...
                [obj.Name,'_normal_force'];
                [obj.Name,'_friction_cone']});
            conds = cell(2,1);
            conds{1} = zeros(1,obj.Dimension);
            conds{1}(n_axis_index==c_indices) = 1;
            if strcmp(model_type, 'planar')
                conds{2} = zeros(2,obj.Dimension);
                conds{2}(:,n_axis_index==c_indices) = mu/sqrt(2)*ones(2,1);
                conds{2}(:,n_axis_index~=c_indices & c_indices <=3 ) = [1; -1];
            else
                conds{2} = zeros(4,obj.Dimension);
                conds{2}(:,n_axis_index==c_indices) = mu/sqrt(2)*ones(4,1);
                conds{2}(:,n_axis_index~=c_indices & c_indices <=3 ) = [1 0; -1 0; 0 1; 0 -1];
            end
            
        case 'PointContactWithoutFriction'
            % normal force
            Names = categorical({[obj.Name,'_normal_force']});
            conds = cell(1,1);
            conds{1} = zeros(1,obj.Dimension);
            conds{1}(n_axis_index==c_indices) = 1;
        case 'LineContactWithFriction'
            
            
            % normal force, friction cone, roll_moment, yaw?
            mu = varargin{1}; % friction coefficient
            axis = varargin{2}; % the binormal axis (roll)
            distance = varargin{3}; % distance to the edge along the negative and positive tangent axis
            assert(~strcmp(axis,obj.NormalAxis) && ...
                ~strcmp(axis,obj.TangentAxis),...
                'The given axis must be different from the normal and tangent axis.');
            b_axis_index = 3 + find(strcmp(axis,{'x','y','z'})); % binormal axis index
            
            Names = categorical({...
                [obj.Name,'_normal_force'];
                [obj.Name,'_friction_cone'];
                [obj.Name,'_roll_moment']});
            assert(strcmp(model_type, 'spatial'),...
                'Line contacts can be only used for spatial model.');
            
            conds = cell(3,1);
            % normal force
            conds{1} = zeros(1,obj.Dimension);
            conds{1}(n_axis_index==c_indices) = 1;
            % friction cone
            conds{2} = zeros(4,obj.Dimension);
            conds{2}(:,n_axis_index==c_indices) = mu/sqrt(2)*ones(4,1);
            conds{2}(:,n_axis_index~=c_indices & c_indices <=3 ) = [1 0; -1 0; 0 1; 0 -1];
            % roll moment
            conds{3} = zeros(2,obj.Dimension);
            conds{3}(:,n_axis_index==c_indices) = distance';
            conds{3}(:,b_axis_index==c_indices) = [-1; 1];
            
            
        case 'LineContactWithoutFriction'
            % normal force, friction cone, roll_moment, yaw?
            axis = varargin{1}; % the binormal axis (roll)
            distance = varargin{2}; % distance to the edge along the negative and positive tangent axis
            assert(~strcmp(axis,obj.NormalAxis) && ...
                ~strcmp(axis,obj.TangentAxis),...
                'The given axis must be different from the normal and tangent axis.');
            b_axis_index = 3 + find(strcmp(axis,{'x','y','z'})); % binormal axis index
            
            conds = cell(2,1);
            % normal force
            conds{1} = zeros(1,obj.Dimension);
            conds{1}(n_axis_index==c_indices) = 1;
            % roll moment
            conds{2} = zeros(2,obj.Dimension);
            conds{2}(:,n_axis_index==c_indices) = distance';
            conds{2}(:,b_axis_index==c_indices) = [-1; 1];
        case 'PlanarContactWithFriction'
            % normal force, friction cone, roll, pitch, yaw?
            mu = varargin{1};
            axis1 = varargin{2}; % the tagential axis (pitch)
            distance1 = varargin{3}; % distance to the edge along the negative and positive binormal axis
            assert(~strcmp(axis1,obj.NormalAxis),...
                'The given axis must be different from the normal axis.');
            t_axis_index = 3 + find(strcmp(axis1,{'x','y','z'})); % binormal axis index
            
            if strcmp(model_type, 'spatial')
                axis2 = varargin{4}; % the binormal axis (roll)
                distance2 = varargin{5}; % distance to the edge along the negative and positive tangent axis
                assert(~strcmp(axis2,obj.NormalAxis),...
                    'The given axis must be different from the normal axis.');
                b_axis_index = 3 + find(strcmp(axis2,{'x','y','z'})); % binormal axis index
                Names = categorical({...
                    [obj.Name,'_normal_force'];
                    [obj.Name,'_friction_cone'];
                    [obj.Name,'_pitch_moment'];
                    [obj.Name,'_roll_moment']});
                conds = cell(4,1);
            else
                Names = categorical({...
                    [obj.Name,'_normal_force'];
                    [obj.Name,'_friction_cone'];
                    [obj.Name,'_pitch_moment']});
                conds = cell(3,1);
            end
            
            
            
            
            
            % normal force
            conds{1} = zeros(1,obj.Dimension);
            conds{1}(n_axis_index==c_indices) = 1;
            % friction cone
            conds{2} = zeros(4,obj.Dimension);
            conds{2}(:,n_axis_index==c_indices) = mu/sqrt(2)*ones(4,1);
            conds{2}(:,n_axis_index~=c_indices & c_indices <=3 ) = [1 0; -1 0; 0 1; 0 -1];
            % pitch moment
            
            conds{3} = zeros(2,obj.Dimension);
            conds{3}(:,n_axis_index==c_indices) = distance1';
            conds{3}(:,t_axis_index==c_indices) = [-1; 1];
            
            if strcmp(model_type, 'spatial')
                % roll moment
                conds{4} = zeros(2,obj.Dimension);
                conds{4}(:,n_axis_index==c_indices) = distance2';
                conds{4}(:,b_axis_index==c_indices) = [-1; 1];
            end
            
        case 'PlanarContactWithoutFriction'
            % normal force, roll, pitch
            
            axis1 = varargin{1}; % the tagential axis (pitch)
            distance1 = varargin{2}; % distance to the edge along the negative and positive binormal axis
            assert(~strcmp(axis1,obj.NormalAxis),...
                'The given axis must be different from the normal axis.');
            t_axis_index = 3 + find(strcmp(axis1,{'x','y','z'})); % binormal axis index
            
            if strcmp(model_type, 'spatial')
                axis2 = varargin{3}; % the binormal axis (roll)
                distance2 = varargin{4}; % distance to the edge along the negative and positive tangent axis
                assert(~strcmp(axis2,obj.NormalAxis),...
                    'The given axis must be different from the normal axis.');
                b_axis_index = 3 + find(strcmp(axis2,{'x','y','z'})); % binormal axis index
                Names = categorical({...
                    [obj.Name,'_normal_force'];
                    [obj.Name,'_pitch_moment'];
                    [obj.Name,'_roll_moment']});
                conds = cell(3,1);
            else
                Names = categorical({...
                    [obj.Name,'_normal_force'];
                    [obj.Name,'_pitch_moment']});
                conds = cell(2,1);
            end
            
            
            
            
            
            % normal force
            conds{1} = zeros(1,obj.Dimension);
            conds{1}(n_axis_index==c_indices) = 1;
            % pitch moment
            
            conds{2} = zeros(2,obj.Dimension);
            conds{2}(:,n_axis_index==c_indices) = distance1';
            conds{2}(:,t_axis_index==c_indices) = [-1; 1];
            
            if strcmp(model_type, 'spatial')
                % roll moment
                conds{3} = zeros(2,obj.Dimension);
                conds{3}(:,n_axis_index==c_indices) = distance2';
                conds{3}(:,b_axis_index==c_indices) = [-1; 1];
            end
        
    end
    
    conditions = table(Names,conds,'VariableName',{'Name','cond'});
   
end
