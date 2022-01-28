function base = get_custom_base()

    base = get_base_dofs('planar');

    % Set base DOF limits
    limits = [base.Limit];

    [limits.lower] = deal(-10, -10, pi/4);
    [limits.upper] = deal(10, 10, pi/4);
    [limits.velocity] = deal(20, 20, 20);
    [limits.effort] = deal(0);
    for i=1:length(base)
        base(i).Limit = limits(i);
    end

end