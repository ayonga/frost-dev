function bounds = getBounds(flippy,behavior_name)
%%  % these are hard limits. Not good to mess with these!!!
    bounds = flippy.getLimits();
    % control input
    bounds.inputs.Control.u.lb = - ones(1,flippy.numState)*Inf;
    bounds.inputs.Control.u.ub = ones(1,flippy.numState)*Inf;

    bounds.params.apos.lb = -600;
    bounds.params.apos.ub = 600;
    % bounds.vel.ep = 10;% y1dot = -ep*y1
    bounds.pos.kp = 100; % y2ddot = -kd*y2dot - kp*y2
    bounds.pos.kd = 10;

    switch(behavior_name)
        case 'j2j'
            % position, velocity, and acceleration
            bounds.states.x.lb = [ -pi/2,   -pi/2,  -1,  -pi, -0.1,  - 2*pi ]; % -1.09 for joint 3 is the minimum limit
            bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2, pi,  2,    2*pi ];
            bounds.states.dx.lb = -10*ones(1,flippy.numState);
            bounds.states.dx.ub =  10*ones(1,flippy.numState);
            bounds.states.ddx.lb = -800*ones(1,flippy.numState);
            bounds.states.ddx.ub =  800*ones(1,flippy.numState);
            % time duration
            bounds.time.t0.lb = 0; % starting time
            bounds.time.t0.ub = 0;
            bounds.time.tf.lb = 0.5; % terminating time
            bounds.time.tf.ub = 4.0;
            bounds.time.duration.lb = 0.5; % duration (optional)
            bounds.time.duration.ub = 4.0;
        case 'trans'
            % position, velocity, and acceleration
            bounds.states.x.lb = [ -pi/2,   -pi/2,  -1,  -pi, -2,   - pi ]; % -1.09 for joint 3 is the minimum limit
            bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2,   pi, 2,    pi ];
            bounds.states.dx.lb = -16*ones(1,flippy.numState);
            bounds.states.dx.ub =  16*ones(1,flippy.numState);
            bounds.states.ddx.lb = -800*ones(1,flippy.numState);
            bounds.states.ddx.ub =  800*ones(1,flippy.numState);
            % time duration
            bounds.time.t0.lb = 0; % starting time
            bounds.time.t0.ub = 0;
            bounds.time.tf.lb = 1.0; % terminating time
            bounds.time.tf.ub = 4.0;
            bounds.time.duration.lb = 1.0; % duration (optional)
            bounds.time.duration.ub = 4.0;
        case 'p2p'
            % position, velocity, and acceleration
            bounds.states.x.lb = [ -pi/2,   -pi/2,  -1,  -pi, -2,   - pi ]; % -1.09 for joint 3 is the minimum limit
            bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2,   pi, 2,    pi ];
            bounds.states.dx.lb = -5*ones(1,flippy.numState);
            bounds.states.dx.ub =  5*ones(1,flippy.numState);
            bounds.states.ddx.lb = -800*ones(1,flippy.numState);
            bounds.states.ddx.ub =  800*ones(1,flippy.numState);
            % time duration
            bounds.time.t0.lb = 0; % starting time
            bounds.time.t0.ub = 0;
            bounds.time.tf.lb = 1.0; % terminating time
            bounds.time.tf.ub = 4.0;
            bounds.time.duration.lb = 1.0; % duration (optional)
            bounds.time.duration.ub = 4.0;
        case 'scoop'
            % position, velocity, and acceleration
            bounds.states.x.lb = [ -pi/2,  -pi/2,     -1,  -2*pi/3, -2, -pi ]; % -1.09 for joint 3 is the minimum limit
            bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2,   2*pi/3,  2,  pi ];
            bounds.states.dx.lb = -10*ones(1,flippy.numState);
            bounds.states.dx.ub =  10*ones(1,flippy.numState);
            bounds.states.ddx.lb = -700*ones(1,flippy.numState);
            bounds.states.ddx.ub =  700*ones(1,flippy.numState);
            % time duration
            bounds.time.t0.lb = 0; % starting time
            bounds.time.t0.ub = 0;
            bounds.time.tf.lb = 0.12; % terminating time
            bounds.time.tf.ub = 1.0;
            bounds.time.duration.lb = 0.12; % duration (optional)
            bounds.time.duration.ub = 1.0;
        case 'pickup'
            % position, velocity, and acceleration
            bounds.states.x.lb = [ -pi/2,   -pi/2,  -1,  -pi, -2,   - pi ]; % -1.09 for joint 3 is the minimum limit
            bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2,   pi, 2,    pi ];
            bounds.states.dx.lb = -8*ones(1,flippy.numState);
            bounds.states.dx.ub =  8*ones(1,flippy.numState);
            bounds.states.ddx.lb = -800*ones(1,flippy.numState);
            bounds.states.ddx.ub =  800*ones(1,flippy.numState);
            % time duration
            bounds.time.t0.lb = 0; % starting time
            bounds.time.t0.ub = 0;
            bounds.time.tf.lb = 0.05; % terminating time
            bounds.time.tf.ub = 1.0;
            bounds.time.duration.lb = 0.05; % duration (optional)
            bounds.time.duration.ub = 1.0;
        case 'flipdrop'
            % position, velocity, and acceleration
            bounds.states.x.lb = [ -pi/2,   -pi/2,  -1,  -2*pi/3, 0,   - 2*pi ]; % -1.09 for joint 3 is the minimum limit
            bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2, 2*pi/3, 2,    2*pi ];
            bounds.states.dx.lb = -16*ones(1,flippy.numState);
            bounds.states.dx.ub =  16*ones(1,flippy.numState);
            bounds.states.ddx.lb = -800*ones(1,flippy.numState);
            bounds.states.ddx.ub =  800*ones(1,flippy.numState);
            % time duration
            bounds.time.t0.lb = 0; % starting time
            bounds.time.t0.ub = 0;
            bounds.time.tf.lb = 0.4; % terminating time
            bounds.time.tf.ub = 1.5;
            bounds.time.duration.lb = 0.4; % duration (optional)
            bounds.time.duration.ub = 1.5;
        case 'drop'
            % position, velocity, and acceleration
            bounds.states.x.lb = [ -pi/2,   -pi/2,  -1,  -pi, -2,   - pi ]; % -1.09 for joint 3 is the minimum limit
            bounds.states.x.ub = [  2.8,  2*pi/3,   pi/2,   pi, 2,    pi ];
            bounds.states.dx.lb = -16*ones(1,flippy.numState);
            bounds.states.dx.ub =  16*ones(1,flippy.numState);
            bounds.states.ddx.lb = -800*ones(1,flippy.numState);
            bounds.states.ddx.ub =  800*ones(1,flippy.numState);
            % time duration
            bounds.time.t0.lb = 0; % starting time
            bounds.time.t0.ub = 0;
            bounds.time.tf.lb = 1.0; % terminating time
            bounds.time.tf.ub = 4.0;
            bounds.time.duration.lb = 1.0; % duration (optional)
            bounds.time.duration.ub = 4.0;
        case default
            error('Behavior type not supported');
    end
end