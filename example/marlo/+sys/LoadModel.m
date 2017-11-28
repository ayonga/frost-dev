function robot = LoadModel(urdf, load_path, delay_set)
    % construct RobotLinks object for CASSIE
    
    if nargin < 2
        load_path = [];
    end
    
    if nargin < 1
        cur = utils.get_root_path();
        urdf = fullfile(cur,'urdf','atrias.urdf');
    end
    
    if nargin < 3
        delay_set = false;
    end
    
    base = get_base_dofs('floating');
    
    limits = [base.Limit];
    
    [limits.lower] = deal(-1, -2, 0.25, -.01, -.01, -0.001);
    [limits.upper] = deal(1, 2, 2, .01, .01, 0.001);
    [limits.velocity] = deal(2, 2, 0.5, 0.5, 0.5, 0.1);
    [limits.effort] = deal(0);
    for i=1:6
        base(i).Limit = limits(i);
    end
    robot = RobotLinks(urdf, base);
    
    % Add 4-bar holonomic constraint
    q = robot.States.x;
    
    h = [...
        q('qARight') - q('qBRight') + q('fourBarARight');
        -q('qARight') + q('qBRight') + q('fourBarBRight');
        q('qALeft') - q('qBLeft') + q('fourBarALeft');
        -q('qALeft') + q('qBLeft') + q('fourBarBLeft');
        ];
    
    
    four_bar_constr = HolonomicConstraint(robot, h, 'fourBar',...
        'ConstrLabel',{{'fourBarARight','fourBarBRight','fourBarALeft','fourBarBLeft'}},...
        'DerivativeOrder',2, 'LoadPath', load_path);
    
    robot = addHolonomicConstraint(robot, four_bar_constr, load_path);
    
    if isempty(load_path)
        configureDynamics(robot, 'DelayCoriolisSet', delay_set);
    else
        loadDynamics(robot, load_path, delay_set);
    end
end

