function [conGUI] = LoadSimAnimator(robot, logger, varargin)
    
    
    t = [];
    q = []; 
    
    for j=1:length(logger)
        t = [t,logger(j).flow.t];         %#ok<*AGROW>
        q = [q,logger(j).flow.states.x];        
    end
    
    robot_disp = LoadRobotDisplay(robot, varargin{:});
    
    anim = frost.Animator.AbstractAnimator(robot_disp, t, q);
    anim.isLooping = true;
    anim.speed = 1;
    anim.pov = frost.Animator.AnimatorPointOfView.North;
    anim.Animate(true);
    conGUI = frost.Animator.AnimatorControls();
    conGUI.anim = anim;
    anim.pov = frost.Animator.AnimatorPointOfView.Free;
end