function robot_disp = LoadDisplay(robot, varargin)
    
    root_path = utils.get_project_path();
    export_path = fullfile(root_path,'export','animator');
    if ~exist(export_path,'dir')
        mkdir(export_path);
    end
    addpath(export_path);
    if nargin > 3
        options = varargin;
    else        
        options = {'UseExported', true, 'ExportPath', export_path, 'SkipExporting', true};
    end

    f = figure(1000);clf;
    robot_disp = frost.Animator.Display(f, robot, options{:});
    
    % add last bar
    torso = CoordinateFrame(...
        'Name','torso',...
        'Reference',robot.Joints(end),...
        'Offset',[0,0,0],...
        'R',[0,0,0]...
        );
    
    name = 'toros';
    offset = [0,0,0.63];
    torso_item = frost.Animator.Cylinder(robot_disp.axs, robot, torso, offset, name, options{:});
    robot_disp.addItem(torso_item);
    
    % add base
    
    
    name = 'Base';
    p1 = [-0.05,-0.02,-0.02];
    p2 = [0.15,0.02,0.02];
    base = frost.Animator.Rectangler(robot_disp.axs, robot, robot.Joints(4), p1, p2, name, options{:});
    robot_disp.addItem(base);
    
    robot_disp.removeItem('Joint_BaseRotY');
    robot_disp.removeItem('Joint_ankle');
    robot_disp.removeItem('Link_foot_to_ankle');
    
    set(robot_disp.axs,'XLim',[-2,2]);
    view(robot_disp.axs,[0,0]);
    
    %     item = robot_disp.items('EndEff');
    %     item.radius = 0.01;
    %     item = robot_disp.items('Joint_joint1');
    %     item.radius = 0.015;
    %     item = robot_disp.items('Joint_joint2');
    %     item.radius = 0.015;
    %     item = robot_disp.items('Link_link1_to_joint2');
    %     item.radius = 0.01;
    robot_disp.update(zeros(robot.numState,1));
end