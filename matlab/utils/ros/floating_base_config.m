function base = floating_base_config(type, base_link)
    % It returns the default configuration of the floating base coordinates
    % of a robot manipulator.
    %
    % Parameters:
    % type: the type of the floating base configuration @type char
    % base_link: the base link of the robot manipulator @type char
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
    %
    % The required fields of Joints:
    %  name: the name of the rigid joint @type char
    %  type: the type of the rigid joint @type char
    %  origin: the position and orientation of the origin @type struct
    %  axis: the rotation axis of the joint @type rowvec
    %  parent: the parent link of the rigid joint @type char
    %  child: the child link of the rigid joint @type char
    %  limit: the limit of the rigid joint @type struct
    %
    % The required fields of origin:
    %  rpy: the (roll,pitch,yaw) rotation of the link origin w.r.t. its
    %  parent joint
    %  xyz: the offset of the link origin w.r.t. its
    %  parent joint
    %
    % The required fields of limit:
    %  effort: the maximum torque effort limit @type double
    %  lower: the lower bound of the joint @type double
    %  upper: the upper bound of the joint @type double
    %  velocity: the maximum velocity limit @type double
    
    
    switch type
        case 'floating'
            base(6) = struct(); % 6-DOF base coordinates
            
            
            % the name of the base dofs 
            [base(1:6).name] = deal('BasePosX','BasePosY','BasePosZ','BaseRotX','BaseRotY','BaseRotZ'); 
            
            % the type of the base dofs
            [base(1:3).type] = deal('prismatic'); % the first three are prismatic joints
            [base(4:6).type] = deal('revolute');  % the last three are revolute joints
            
            % the origin are all zeros
            origin.xyz = [0,0,0];
            origin.rpy = [0,0,0];
            [base.origin] = deal(origin);
            
            % the axis of the base dofs
            [base(1:3).axis] = deal([1,0,0],[0,1,0],[0,0,1]);
            [base(4:6).axis] = deal([1,0,0],[0,1,0],[0,0,1]);
            
            % the parent link of the base dofs
            [base.parent] =  deal('Origin', 'BasePosX','BasePosY','BasePosZ','BaseRotX','BaseRotY'); 
            
            % the child link of the base dofs
            [base.child] = deal('BasePosX','BasePosY','BasePosZ','BaseRotX','BaseRotY',base_link);
            
            % the limitation of the base dofs
            [limit(1:6).effort] = deal(0);
            [limit(1:6).lower] = deal(-inf, -inf, -inf, -pi, -pi, -pi);
            [limit(1:6).upper] = deal(inf, inf, inf, pi, pi, pi);
            [limit(1:6).velocity] = deal(10);
            for i=1:6
                base(i).limit = limit(i);
            end
        case 'planar'
            base(3) = struct(); % 6-DOF base coordinates
            
            
            % the name of the base dofs 
            [base(1:3).name] = deal('BasePosX','BasePosZ','BaseRotY'); 
            
            % the type of the base dofs
            [base(1:2).type] = deal('prismatic'); % the first two are prismatic joints
            [base(3).type] = deal('revolute');  % the last one is a revolute joint
            
            % the origin are all zeros
            origin.xyz = [0,0,0];
            origin.rpy = [0,0,0];
            [base.origin] = deal(origin);
            
            % the axis of the base dofs
            [base(1:3).axis] = deal([1,0,0],[0,0,1],[0,1,0]);
            
            % the parent link of the base dofs
            [base.parent] =  deal('Origin', 'BasePosX','BasePosZ'); 
            
            % the child link of the base dofs
            [base.child] = deal('BasePosX','BasePosZ',base_link);
            
            % the limitation of the base dofs
            [limit(1:3).effort] = deal(0);
            [limit(1:3).lower] = deal(-inf,  -inf, -pi);
            [limit(1:3).upper] = deal(inf, inf, pi);
            [limit(1:3).velocity] = deal(10);
            for i=1:3
                base(i).limit = limit(i);
            end
        case {'revolute','continuous'}
            base = struct(); % 6-DOF base coordinates
            
            
            % the name of the base dofs 
            base.name = 'BaseRotY'; 
            
            % the type of the base dofs
            base.type = 'revolute';  % the dof is a revolute joint
            
            % the origin are all zeros
            base.origin.xyz = [0,0,0];
            base.origin.rpy = [0,0,0];
            
            % the axis of the base dofs
            base.axis = [0,1,0];
            
            % the parent link of the base dofs
            base.parent=  'Origin'; 
            
            % the child link of the base dofs
            base.child = base_link;
            
            % the limitation of the base dofs
            base.limit.effort = 0;
            base.limit.lower = -pi;
            base.limit.upper = pi;
            base.limit.velocity = 10;
        case 'prismatic'
            base = struct(); % 6-DOF base coordinates
            
            
            % the name of the base dofs 
            base.name = 'BarRotZ'; 
            
            % the type of the base dofs
            base.type = 'prismatic';  % the dof is a prismatic joint
            
            % the origin are all zeros
            base.origin.xyz = [0,0,0];
            base.origin.rpy = [0,0,0];
            
            % the axis of the base dofs
            base.axis = [0,0,1];
            
            % the parent link of the base dofs
            base.parent=  'Origin'; 
            
            % the child link of the base dofs
            base.child = base_link;
            
            % the limitation of the base dofs
            base.limit.effort = 0;
            base.limit.lower = -inf;
            base.limit.upper = inf;
            base.limit.velocity = 10;
        case 'fixed'
            base = [];
        otherwise
            error('Invalid base joint type.\n');
    end
    
    
   
    
end

