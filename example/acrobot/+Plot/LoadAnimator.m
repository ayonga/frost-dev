function [conGUI] = LoadAnimator(robot, gait, varargin)
    
    np = length(gait);
    
    t = [];
    q = [];
    for i=1:2:np
        t = [t, gait(i).tspan]; %#ok<*AGROW>
        q = [q, gait(i).states.x];
    end

    %     if length(gait) == 1
    %         t = gait.tspan;
    %         q = gait.states.x;
    %     else
    %         t = [gait(1).tspan,gait(3).tspan, gait(5).tspan];
    %         q = [gait(1).states.x,gait(3).states.x, gait(5).states.x];
    %     end
    
    robot_disp = Plot.LoadDisplay(robot, varargin{:});
    
    anim = frost.Animator.AbstractAnimator(robot_disp, t, q);
    anim.isLooping = false;
    anim.speed = 0.25;
    anim.pov = frost.Animator.AnimatorPointOfView.Free;
    anim.Animate(true);
    conGUI = frost.Animator.AnimatorControls();
    conGUI.anim = anim;
end