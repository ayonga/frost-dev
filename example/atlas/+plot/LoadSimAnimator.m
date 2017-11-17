function [conGUI] = LoadSimAnimator(robot, logger, varargin)
    
    
    
    
    t = [];
    q = []; 
    
    for j=1:numel(logger)
        t = [t,logger(j).flow.t];         %#ok<*AGROW>
        q = [q,logger(j).flow.states.x];        
    end
    
    exo_disp = plot.LoadRobotDisplay(robot, varargin{:});
    
    anim = frost.Animator.AbstractAnimator(exo_disp, t, q);
    anim.isLooping = true;
    anim.speed = 1;
    anim.pov = frost.Animator.AnimatorPointOfView.Free;
    anim.Animate(true);
    conGUI = frost.Animator.AnimatorControls();
    conGUI.anim = anim;
end