function conditions = getWrenchConstraintTable(obj)
    % Returns all admissible conditions of contact wrenches 
    %
    % 
    % Return values:
    % cond_tab: admissible conditions of type table
    %
    % @todo This function not has been heavily tested yet. Plase use it
    % after testing the particular cases you use.
    
    c_indices = obj.ConstrIndices;
    
    n_axis_index = find(strcmp(obj.NormalAxis,{'x','y','z'})); % normal axis index
    n_axis_sign = obj.NormalAxisSign;
    c_name = obj.Name;
    
    model_type = obj.ModelType;
    dimension = length(c_indices);
    
    switch obj.ContactType
        case 'PointContactWithFriction'
            % normal force (1), friction cone (4)
            assert(~isempty(obj.Mu),'The friction coefficient ''Mu'' is NOT assigned.');
            mu = obj.Mu; % friction coefficient
            Names = {...
                [c_name,'_normal_force'];
                [c_name,'_friction_cone']};
            conds = cell(2,1);
            conds{1} = zeros(1,dimension);
            conds{1}(n_axis_index==c_indices) = n_axis_sign;
            if strcmp(model_type, 'planar')
                conds{2} = zeros(2,dimension);
                conds{2}(:,n_axis_index==c_indices) = n_axis_sign*mu/sqrt(2)*ones(2,1);
                conds{2}(:,n_axis_index~=c_indices & c_indices <=3 ) = [1; -1];
            else
                conds{2} = zeros(4,dimension);
                conds{2}(:,n_axis_index==c_indices) = n_axis_sign*mu/sqrt(2)*ones(4,1);
                conds{2}(:,n_axis_index~=c_indices & c_indices <=3 ) = [1 0; -1 0; 0 1; 0 -1];
            end
            
        case 'PointContactWithoutFriction'
            % normal force
            Names = {[c_name,'_normal_force']};
            conds = cell(1,1);
            conds{1} = zeros(1,dimension);
            conds{1}(n_axis_index==c_indices) = n_axis_sign;
        case 'LineContactWithFriction'
            
            assert(~isempty(obj.Mu),'The friction coefficient ''Mu'' is NOT assigned.');
            assert(size(obj.Geometry,1)==1, ...
                'For line contacts, only one dimensional geometry data required.');
            % normal force, friction cone, roll_moment, yaw?
            mu = obj.Mu; % friction coefficient
            axis = obj.Geometry{1,1}; % the binormal axis (roll)
            distance = obj.Geometry{1,2}; % distance to the edge 
            assert(~strcmp(axis,obj.NormalAxis) && ...
                ~strcmp(axis,obj.TangentAxis),...
                'The given axis must be different from the normal and tangent axis.');
            b_axis_index = 3 + find(strcmp(axis,{'x','y','z'})); % binormal axis index
            
            Names = {...
                [c_name,'_normal_force'];
                [c_name,'_friction_cone'];
                [c_name,'_roll_moment_pos'];
                [c_name,'_roll_moment_neg']};
            assert(strcmp(model_type, 'spatial'),...
                'Line contacts can be only used for spatial model.');
            
            conds = cell(4,1);
            % normal force
            conds{1} = zeros(1,dimension);
            conds{1}(n_axis_index==c_indices) = n_axis_sign;
            % friction cone
            conds{2} = zeros(4,dimension);
            conds{2}(:,n_axis_index==c_indices) = n_axis_sign*mu/sqrt(2)*ones(4,1);
            conds{2}(:,n_axis_index~=c_indices & c_indices <=3 ) = [1 0; -1 0; 0 1; 0 -1];
            % roll moment
            conds{3} = zeros(1,dimension);
            conds{3}(:,n_axis_index==c_indices) = n_axis_sign*distance(1);
            conds{3}(:,b_axis_index==c_indices) = -1;
            
            conds{4} = zeros(1,dimension);
            conds{4}(:,n_axis_index==c_indices) = n_axis_sign*distance(2);
            conds{4}(:,b_axis_index==c_indices) = 1;
            
        case 'LineContactWithoutFriction'
            % normal force, friction cone, roll_moment, yaw?
            assert(size(obj.Geometry,1)==1, ...
                'For line contacts, only one dimensional geometry data required.');
            axis = obj.Geometry{1,1}; % the binormal axis (roll)
            distance = obj.Geometry{1,2}; % distance to the edge 
            assert(~strcmp(axis,obj.NormalAxis) && ...
                ~strcmp(axis,obj.TangentAxis),...
                'The given axis must be different from the normal and tangent axis.');
            b_axis_index = 3 + find(strcmp(axis,{'x','y','z'})); % binormal axis index
            
             Names = {...
                [c_name,'_normal_force'];
                [c_name,'_roll_moment_pos'];
                [c_name,'_roll_moment_neg']};
            
            conds = cell(3,1);
            % normal force
            conds{1} = zeros(1,dimension);
            conds{1}(n_axis_index==c_indices) = 1;
            % roll moment
            conds{2} = zeros(1,dimension);
            conds{2}(:,n_axis_index==c_indices) = n_axis_sign*distance(1);
            conds{2}(:,b_axis_index==c_indices) = -1;
            
            
            conds{3} = zeros(1,dimension);
            conds{3}(:,n_axis_index==c_indices) = n_axis_sign*distance(2);
            conds{3}(:,b_axis_index==c_indices) = 1;
        case 'PlanarContactWithFriction'
            % normal force, friction cone, roll, pitch, yaw?
            assert(~isempty(obj.Mu),'The friction coefficient ''Mu'' is NOT assigned.');
            mu = obj.Mu; % friction coefficient
            
            
            
            
            if strcmp(model_type, 'spatial')
                assert(size(obj.Geometry,1)==2, ...
                    'For planar contacts of spatial model, two dimensional geometry data required.');
                
                axis1 = obj.Geometry{1,1}; % the binormal axis (roll)
                distance1 = obj.Geometry{1,2}; % distance to the edge
                
                axis2 = obj.Geometry{2,1}; % the binormal axis (roll)
                distance2 = obj.Geometry{2,2}; % distance to the edge along the negative and positive tangent axis
                assert(~strcmp(axis2,obj.NormalAxis),...
                    'The given axis must be different from the normal axis.');
                b_axis_index = 3 + find(strcmp(axis2,{'x','y','z'})); % binormal axis index
                Names = {...
                    [c_name,'_normal_force'];
                    [c_name,'_friction_cone'];
                    [c_name,'_pitch_moment_pos'];
                    [c_name,'_pitch_moment_neg'];
                    [c_name,'_roll_moment_pos'];
                    [c_name,'_roll_moment_neg']};
                conds = cell(6,1);
            else
                assert(size(obj.Geometry,1)==1, ...
                    'For planar contacts of planar model, only one dimensional geometry data required.');
                
                axis1 = obj.Geometry{1,1}; % the binormal axis (roll)
                distance1 = obj.Geometry{1,2}; % distance to the edge
                Names = {...
                    [c_name,'_normal_force'];
                    [c_name,'_friction_cone'];
                    [c_name,'_pitch_moment_pos'];
                    [c_name,'_pitch_moment_neg'];};
                conds = cell(4,1);
            end
            
            assert(~strcmp(axis1,obj.NormalAxis),...
                'The given axis must be different from the normal axis.');
            t_axis_index = 3 + find(strcmp(axis1,{'x','y','z'})); % binormal axis index
            
            
            
            % normal force
            conds{1} = zeros(1,dimension);
            conds{1}(n_axis_index==c_indices) = n_axis_sign;
            % friction cone
            conds{2} = zeros(4,dimension);
            conds{2}(:,n_axis_index==c_indices) = n_axis_sign*mu/sqrt(2)*ones(4,1);
            conds{2}(:,n_axis_index~=c_indices & c_indices <=3 ) = [1 0; -1 0; 0 1; 0 -1];
            % pitch moment
            
            conds{3} = zeros(1,dimension);
            conds{3}(:,n_axis_index==c_indices) = n_axis_sign*distance1(1);
            conds{3}(:,t_axis_index==c_indices) = -1;
            
            conds{4} = zeros(1,dimension);
            conds{4}(:,n_axis_index==c_indices) = n_axis_sign*distance1(2);
            conds{4}(:,t_axis_index==c_indices) = 1;
            
            if strcmp(model_type, 'spatial')
                % roll moment
                conds{5} = zeros(1,dimension);
                conds{5}(:,n_axis_index==c_indices) = n_axis_sign*distance2(1);
                conds{5}(:,b_axis_index==c_indices) = -1;
                
                conds{6} = zeros(1,dimension);
                conds{6}(:,n_axis_index==c_indices) = n_axis_sign*distance2(2);
                conds{6}(:,b_axis_index==c_indices) = 1;
            end
            
        case 'PlanarContactWithoutFriction'
            % normal force, roll, pitch
            
            if strcmp(model_type, 'spatial')
                assert(size(obj.Geometry,1)==2, ...
                    'For planar contacts of spatial model, two dimensional geometry data required.');
                
                axis1 = obj.Geometry{1,1}; % the binormal axis (roll)
                distance1 = obj.Geometry{1,2}; % distance to the edge
                
                axis2 = obj.Geometry{2,1}; % the binormal axis (roll)
                distance2 = obj.Geometry{2,2}; % distance to the edge along the negative and positive tangent axis
                assert(~strcmp(axis2,obj.NormalAxis),...
                    'The given axis must be different from the normal axis.');
                b_axis_index = 3 + find(strcmp(axis2,{'x','y','z'})); % binormal axis index
                Names = {...
                    [c_name,'_normal_force'];
                    [c_name,'_pitch_moment_pos'];
                    [c_name,'_pitch_moment_neg'];
                    [c_name,'_roll_moment_pos'];
                    [c_name,'_roll_moment_neg']};
                conds = cell(5,1);
            else
                assert(size(obj.Geometry,1)==1, ...
                    'For planar contacts of planar model, only one dimensional geometry data required.');
                
                axis1 = obj.Geometry{1,1}; % the binormal axis (roll)
                distance1 = obj.Geometry{1,2}; % distance to the edge
                Names = {...
                    [c_name,'_normal_force'];
                    [c_name,'_pitch_moment_pos'];
                    [c_name,'_pitch_moment_neg'];};
                conds = cell(3,1);
            end
            
            assert(~strcmp(axis1,obj.NormalAxis),...
                'The given axis must be different from the normal axis.');
            t_axis_index = 3 + find(strcmp(axis1,{'x','y','z'})); % binormal axis index
            
            
            
            
            
            % normal force
            conds{1} = zeros(1,dimension);
            conds{1}(n_axis_index==c_indices) = n_axis_sign;
            % pitch moment
            
            conds{2} = zeros(1,dimension);
            conds{2}(:,n_axis_index==c_indices) = n_axis_sign*distance1(1);
            conds{2}(:,t_axis_index==c_indices) = -1;
            
            conds{3} = zeros(1,dimension);
            conds{3}(:,n_axis_index==c_indices) = n_axis_sign*distance1(2);
            conds{3}(:,t_axis_index==c_indices) = 1;
            
            if strcmp(model_type, 'spatial')
                % roll moment
                conds{4} = zeros(1,dimension);
                conds{4}(:,n_axis_index==c_indices) = n_axis_sign*distance2(1);
                conds{4}(:,b_axis_index==c_indices) = -1;
                
                conds{5} = zeros(1,dimension);
                conds{5}(:,n_axis_index==c_indices) = n_axis_sign*distance2(2);
                conds{5}(:,b_axis_index==c_indices) = 1;
            end
        
    end
    
    conditions = table(Names,conds,'VariableName',{'Name','cond'});
   
end
