function [rabbit, rabbit_1step] = load_model(urdf)
    %% Create a RobotLink model for the RABBIT robot:
    base = get_custom_base();
    rabbit = RobotLinks(urdf,base);

    %% Create a single domain periodic walking gait (HybridSystem Object)
    r_stance = copy(rabbit);
    r_stance.Name = 'RightStance';

    % Define contact point
    right_toe = right_toe_frame(r_stance);
    right_toe_contact = ToContactFrame(right_toe,'PlanarPointContactWithFriction');
    fric_coef.mu = 0.6;
    addContact(r_stance,right_toe_contact,fric_coef);
    r_stance.CustomNLPConstraint = str2func('right_stance_constraints');

    % Define the event function for the domain
    left_toe = left_toe_frame(r_stance);
    p_nsf = getCartesianPosition(r_stance, left_toe);
    h_nsf_fun = SymFunction('nsf_height',p_nsf(3),{r_stance.States.x});
    h_nsf_constr = EventFunction(h_nsf_fun, r_stance);
    % often very simple, no need to load expression. Compute them directly
    addEvent(r_stance, h_nsf_constr);

    ya = tomatrix(r_stance.States.x(4:end));
    t = SymVariable('t');
    p = ParamVariable('pOutputs',[2,1],[0;0.25],[0;0.75]);
    tau = (t-p(1))/(p(2)-p(1));
    %     q_output = VirtualConstraint('Outputs',ya,r_stance,...
    %         'DesiredType','BSpline',...
    %         'NumKnotPoint',11,...
    %         'NumControlPoint',7,...
    %         'RelativeDegree',2,...
    %         'PhaseType','TimeBased',...
    %         'PhaseVariable',tau,...
    %         'PhaseParams',p,...
    %     'IsHolonomic',true);
    q_output = VirtualConstraint('Outputs',ya,r_stance,...
        'DesiredType','Bezier',...
        'NumControlPoint',5,...
        'RelativeDegree',2,...
        'PhaseType','TimeBased',...
        'PhaseVariable',tau,...
        'PhaseParams',p,...
        'IsHolonomic',true);
    r_stance.addVirtualConstraint(q_output);


    l_impact = RigidImpact('LeftImpact', r_stance, h_nsf_constr);
    l_impact.R = l_impact.R(:,[1:3,6:7,4:5]); % relabel coordinates between left and right legs
    l_impact.CustomNLPConstraint = str2func('left_impact_constraints');

    % Define hybrid system
    rabbit_1step = HybridSystem('Rabbit_1step');
    rabbit_1step = addVertex(rabbit_1step, 'RightStance', 'Domain', r_stance);

    srcs = {'RightStance'};
    tars = {'RightStance'};

    rabbit_1step = addEdge(rabbit_1step, srcs, tars);
    rabbit_1step = setEdgeProperties(rabbit_1step, srcs, tars, ...
        'Guard', {l_impact});
end

