function robot_disp = LoadRobotDisplay(robot, varargin)
    
    
    
    
    
    ip = inputParser;
    ip.addParameter('UseExported',true,@(x) isequal(x,true) || isequal(x,false));
    ip.addParameter('ExportPath','',@(x)ischar(x));
    ip.addParameter('SkipExporting',false,@(x) isequal(x,true) || isequal(x,false));
    
    ip.parse(varargin{:});
    
    opts = ip.Results;
    if isempty(opts.ExportPath)
        root_path = utils.get_root_path();
        export_path = fullfile(root_path,'gen','animator');
        opts.ExportPath = export_path;
    else
        export_path = opts.ExportPath;
    end
    if ~exist(export_path,'dir')
        mkdir(export_path);
    end
    addpath(export_path);
    
    f = figure(1000);clf;
    robot_disp = frost.Animator.Display(f, robot, opts);frame  = robot.Joints(6);
    
    
    pelvis = robot.Links(getLinkIndices(robot,'mtorso'));    
    offset = pelvis.Offset;    
    torso_bar = frost.Animator.Cylinder(robot_disp.axs, robot, frame, offset, 'TorsoBar', opts);
    robot_disp.addItem(torso_bar);
    
    torso = frost.Animator.LinkSphere(robot_disp.axs, robot, pelvis, 'TorsoCoM', opts);
    torso.radius = 0.1;
    robot_disp.addItem(torso);
    % add feet
    left_foot = sys.frames.LeftSole(robot);
    param = sys.GetExtraParams;
    name = 'LeftFoot';
    top_offset = [0,0,-param.hf];
    wf = param.wf;
    lt = param.lt;
    lh = param.lh;
    bottom_offset = [lt,-wf/2,0;
        lt,wf/2,0;
        -lh,wf/2,0;
        -lh,-wf/2,0
        ];
    left_foot = frost.Animator.Pyramid(robot_disp.axs, robot, left_foot, top_offset, bottom_offset, name, opts);
    robot_disp.addItem(left_foot);
    
    
    right_foot = sys.frames.RightSole(robot);
    param = sys.GetExtraParams;
    name = 'RightFoot';
    top_offset = [0,0,-param.hf];
    wf = param.wf;
    lt = param.lt;
    lh = param.lh;
    bottom_offset = [lt,-wf/2,0;
        lt,wf/2,0;
        -lh,wf/2,0;
        -lh,-wf/2,0
        ];
    right_foot = frost.Animator.Pyramid(robot_disp.axs, robot, right_foot, top_offset, bottom_offset, name, opts);
    robot_disp.addItem(right_foot);
    
    
end