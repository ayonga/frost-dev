function robot_disp = LoadRobotDisplay(robot, varargin)
    
    
    
    
    
    ip = inputParser;
    ip.addParameter('UseExported',true,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('ExportPath','',@(x)ischar(x));
    ip.addParameter('SkipExporting',false,@(x) isequal(x,true) || isequal(x,false));
    
    ip.parse(varargin{:});
    
    opts = ip.Results;
    if isempty(opts.ExportPath)
        export_path = fullfile(pwd,'gen','animator');
        opts.ExportPath = export_path;
    else
        export_path = opts.ExportPath;
    end
    if ~exist(export_path,'dir')
        mkdir(export_path);
    end
    addpath(export_path);
    
    f = figure();clf;
    robot_disp = frost.Animator.Display(f, robot, opts);
    
    pelvis_frame = robot.Joints(getJointIndices(robot, 'BaseRotY'));
    offset = [0,0,0.63];    
    torso_bar = frost.Animator.Cylinder(robot_disp.axs, robot, pelvis_frame, offset, 'TorsoBar', opts);
    robot_disp.addItem(torso_bar);
    
    
    
    % left toe
    l_knee_frame = robot.Joints(getJointIndices(robot, 'q2_left'));
    offset = [0,0,0.4];
    item = frost.Animator.Cylinder(robot_disp.axs, robot, l_knee_frame, offset, 'LeftFoot', opts);
    robot_disp.addItem(item);
    
        
    % right toe
    r_knee_frame = robot.Joints(getJointIndices(robot, 'q2_right'));
    offset = [0,0,0.4];
    item = frost.Animator.Cylinder(robot_disp.axs, robot, r_knee_frame, offset, 'RightFoot', opts);
    robot_disp.addItem(item);
    
    
end