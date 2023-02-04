function robot = LoadModel(urdf, load_path)
    % construct RobotLinks object for CASSIE
    
    
    if nargin < 1
        cur = utils.get_root_path();
        urdf = fullfile(cur,'urdf','atlas_simple_contact_noback.urdf');
    end

    if nargin < 2
        load_path = [];
    end

    % base = sys.GetCustomBase(); % user-specified custom base coordinates
    base = get_base_dofs('floating');
            
    limits = [base.Limit];
    
    [limits.lower] = deal(-0.6, -0.2, 0.7, -0.1, -0.5, -0.1);
    [limits.upper] = deal(0.3, 0.2, 1.0, 0.1, 0.5, 0.1);
    [limits.velocity] = deal(1, 0.1, 0.5, 0.5, 0.5, 0.5);
    [limits.effort] = deal(0);
    for i=1:6
        base(i).Limit = limits(i);
    end
    robot = sys.AtlasModel(urdf, base, load_path);
    %     robot = RobotLinks(urdf,base,'LoadPath',load_path);
    
    
end

