function base_dofs = get_base_dofs(type)
    % It returns the default configuration of the floating base coordinates
    % of a robot manipulator.
    %
    % Parameters:
    % type: the type of the floating base configuration @type char
    %
    % Return values:
    % base: the array of base coordinates @type struct
    %
    % @note The supported base joint types are:
    %   - floating: This joint allows motion for all 6 degrees of
    %   freedom. (default axes: {'Px','Py','Pz','Rx','Ry','Rz'})
    %   - planar: This joint allows motion in a plane perpendicular to
    %   the axis. (default axes: {'px','pz','r'})
    %   - revolute: a hinge joint that rotates along the axis and has a
    %   limited range specified by the upper and lower limits. (default
    %   axes: 'r')
    %   - continuous: a continuous hinge joint that rotates around the
    %   axis and has no upper and lower limits. (default
    %   axes: 'r')
    %   - prismatic: a sliding joint that slides along the axis, and
    %   has a limited range specified by the upper and lower limits. (default
    %   axes: 'pz')
    %   - fixed: This is not really a joint because it cannot move. All
    %   degrees of freedom are locked. This type of joint does not
    %   require the axis, calibration, dynamics, limits or
    %   safety_controller. (default axes: [])
    % For more definition regarding the supported joint type, please
    % see the URDF joint description at
    % http://wiki.ros.org/urdf/XML/joint
    
    % validate the base coordinate type
    validatestring(type,{'floating','planar','revolute','prismatic','continuous','fixed'});
    
    switch type
        case 'floating'
            base_dofs(6) = struct(); % 6-DOF base coordinates
            
            
            % the name of the base dofs 
            [base_dofs(1:6).Name] = deal('BasePosX','BasePosY','BasePosZ','BaseRotX','BaseRotY','BaseRotZ'); 
            
            % the type of the base dofs
            [base_dofs(1:3).Type] = deal('prismatic'); % the first three are prismatic joints
            [base_dofs(4:6).Type] = deal('revolute');  % the last three are revolute joints
            
            % the origin are all zeros
            [base_dofs.Offset] = deal([0,0,0]);
            [base_dofs.R] = deal([0,0,0]);
            
            % the axis of the base dofs
            [base_dofs(1:3).Axis] = deal([1,0,0],[0,1,0],[0,0,1]);
            [base_dofs(4:6).Axis] = deal([1,0,0],[0,1,0],[0,0,1]);
            
            % the parent link of the base dofs
            [base_dofs.Parent] =  deal('Origin', 'BasePosX','BasePosY','BasePosZ','BaseRotX','BaseRotY'); 
            
            % the child link of the base dofs
            [base_dofs.Child] = deal('BasePosX','BasePosY','BasePosZ','BaseRotX','BaseRotY','');
            
            % the limitation of the base dofs
            [limit(1:6).effort] = deal(0);
            [limit(1:6).lower] = deal(-inf, -inf, -inf, -pi, -pi, -pi);
            [limit(1:6).upper] = deal(inf, inf, inf, pi, pi, pi);
            [limit(1:6).velocity] = deal(inf);
            for i=1:6
                base_dofs(i).Limit = limit(i);
            end
        case 'planar'
            base_dofs(3) = struct(); % 6-DOF base coordinates
            
            
            % the name of the base dofs 
            [base_dofs(1:3).Name] = deal('BasePosX','BasePosZ','BaseRotY'); 
            
            % the type of the base dofs
            [base_dofs(1:2).Type] = deal('prismatic'); % the first two are prismatic joints
            [base_dofs(3).Type] = deal('revolute');  % the last one is a revolute joint
            
            % the origin are all zeros
            [base_dofs.Offset] = deal([0,0,0]);
            [base_dofs.R] = deal([0,0,0]);
            
            % the axis of the base dofs
            [base_dofs(1:3).Axis] = deal([1,0,0],[0,0,1],[0,1,0]);
            
            % the parent link of the base dofs
            [base_dofs.Parent] =  deal('Origin', 'BasePosX','BasePosZ'); 
            
            % the child link of the base dofs
            [base_dofs.Child] = deal('BasePosX','BasePosZ','');
            
            % the limitation of the base dofs
            [limit(1:3).effort] = deal(0);
            [limit(1:3).lower] = deal(-inf,  -inf, -pi);
            [limit(1:3).upper] = deal(inf, inf, pi);
            [limit(1:3).velocity] = deal(inf);
            for i=1:3
                base_dofs(i).Limit = limit(i);
            end
        case {'revolute','continuous'}
            base_dofs = struct(); % 6-DOF base coordinates
            
            
            % the name of the base dofs 
            base_dofs.Name = 'BaseRotY'; 
            
            % the type of the base dofs
            base_dofs.Type = 'revolute';  % the dof is a revolute joint
            
            % the origin are all zeros
            [base_dofs.Offset] = deal([0,0,0]);
            [base_dofs.R] = deal([0,0,0]);
            
            % the axis of the base dofs
            base_dofs.Axis = [0,1,0];
            
            % the parent link of the base dofs
            base_dofs.Parent=  'Origin'; 
            
            % the child link of the base dofs
            base_dofs.Child = '';
            
            % the limitation of the base dofs
            base_dofs.Limit.effort = 0;
            base_dofs.Limit.lower = -pi;
            base_dofs.Limit.upper = pi;
            base_dofs.Limit.velocity = inf;
        case 'prismatic'
            base_dofs = struct(); % 6-DOF base coordinates
            
            
            % the name of the base dofs 
            base_dofs.Name = 'BasePosZ'; 
            
            % the type of the base dofs
            base_dofs.Type = 'prismatic';  % the dof is a prismatic joint
            
            % the origin are all zeros
            [base_dofs.Offset] = deal([0,0,0]);
            [base_dofs.R] = deal([0,0,0]);
            
            % the axis of the base dofs
            base_dofs.Axis = [0,0,1];
            
            % the parent link of the base dofs
            base_dofs.Parent=  'Origin'; 
            
            % the child link of the base dofs
            base_dofs.Child = '';
            
            % the limitation of the base dofs
            base_dofs.Limit.effort = 0;
            base_dofs.Limit.lower = -inf;
            base_dofs.Limit.upper = inf;
            base_dofs.Limit.velocity = inf;
        case 'fixed'
            base_dofs = [];
        otherwise
            error('Invalid base joint type.\n');
    end
    
    
   
    
end

