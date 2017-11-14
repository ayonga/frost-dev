function Behavior = validatePickAndFlipBehaviorBox(Behavior,boxes,pose_home,pose_start,pose_burger)
    %% this function checks if p_start p_end are on table side or grill size
    
    p_start = pose_start.position;
    p_burger = pose_burger.position;
    p_home = pose_home.position;
    q_home = getHomeConfiguration();
    
    % this is burger related positions assuming spatula is always parallel
    % to x axis
    burger = getBurgerSpecs();
    spatula = getSpatulaSpecs();
    
    % approaching the burger before scoop
    approach_offset = burger.outer_diameter; % this is the offset from burger center where spatula center should locate before scoop operation
    approach_orientation = 0.314;
    
    pose_approach.position = p_burger + [-approach_offset, 0, spatula.length/2*sin(approach_orientation)];
    pose_approach.orientation = [0,approach_orientation,0];
    % final burger pose after pickup
    pose_pickup.position = p_burger + [0.02,0,0.05];
    pose_pickup.orientation = [0,-0.05,0];
    
    if isInGrillBox(p_start,boxes.grill_box) && isInGrillBox(p_burger,boxes.grill_box)
        Behavior.nSubBehaviors = 5;
        Behavior.sub_behavior_names = {'p2p','scoop','pickup','flipdrop','j2j'};
        Behavior.SubBehavior(1).name = 'p2p';
        Behavior.SubBehavior(1).description = 'translate_to_starting_position_for_pickup';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_approach;
        Behavior.SubBehavior(1).box = boxes.grill_box;
        Behavior.SubBehavior(1).qstart = [];
        Behavior.SubBehavior(1).qend = [];
        Behavior.SubBehavior(1).dqstart = [];
        Behavior.SubBehavior(1).dqend = [];
        Behavior.SubBehavior(2).name = 'scoop';
        Behavior.SubBehavior(2).description = 'scoop_the_burger';
        Behavior.SubBehavior(2).pose_start = pose_approach;
        Behavior.SubBehavior(2).pose_end = pose_burger;
        Behavior.SubBehavior(2).box = boxes.grill_box;
        Behavior.SubBehavior(2).qstart = [];
        Behavior.SubBehavior(2).qend = [];
        Behavior.SubBehavior(2).dqstart = [];
        Behavior.SubBehavior(2).dqend = [];
        Behavior.SubBehavior(3).name = 'pickup';
        Behavior.SubBehavior(3).description = 'pickup_the_burger';
        Behavior.SubBehavior(3).pose_start = pose_burger;
        Behavior.SubBehavior(3).pose_end = pose_pickup;
        Behavior.SubBehavior(3).box = boxes.grill_box;
        Behavior.SubBehavior(3).qstart = [];
        Behavior.SubBehavior(3).qend = [];
        Behavior.SubBehavior(3).dqstart = [];
        Behavior.SubBehavior(3).dqend = [];
        Behavior.SubBehavior(4).name = 'flipdrop';
        Behavior.SubBehavior(4).description = 'flip_the_burger';
        Behavior.SubBehavior(4).pose_start = pose_pickup;
        Behavior.SubBehavior(4).pose_end = pose_burger;
        Behavior.SubBehavior(4).box = boxes.grill_box;
        Behavior.SubBehavior(4).qstart = [];
        Behavior.SubBehavior(4).qend = [];
        Behavior.SubBehavior(4).dqstart = [];
        Behavior.SubBehavior(4).dqend = [];
        Behavior.SubBehavior(5).name = 'j2j';
        Behavior.SubBehavior(5).description = 'turn_spatula_back';
        Behavior.SubBehavior(5).pose_start = [];
        Behavior.SubBehavior(5).pose_end = pose_home;
        Behavior.SubBehavior(5).box = boxes.grill_box;
        Behavior.SubBehavior(5).qstart = [];
        Behavior.SubBehavior(5).qend = q_home;
        Behavior.SubBehavior(5).dqstart = [];
        Behavior.SubBehavior(5).dqend = [];
    elseif isInTableBox(p_start,boxes.table_box) && isInGrillBox(p_burger,boxes.grill_box)
        Behavior.nSubBehaviors = 6;
        Behavior.sub_behavior_names = {'trans','p2p','scoop','pickup','flipdrop','j2j'};
        Behavior.SubBehavior(1).name = 'trans';
        Behavior.SubBehavior(1).description = 'translate_to_home';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_home;
        Behavior.SubBehavior(1).box = boxes.grill_box;
        Behavior.SubBehavior(1).qstart = [];
        Behavior.SubBehavior(1).qend = [];
        Behavior.SubBehavior(1).dqstart = [];
        Behavior.SubBehavior(1).dqend = [];
        Behavior.SubBehavior(2).name = 'p2p';
        Behavior.SubBehavior(2).description = 'translate_to_starting_position_for_pickup';
        Behavior.SubBehavior(2).pose_start = pose_home;
        Behavior.SubBehavior(2).pose_end = pose_approach;
        Behavior.SubBehavior(2).box = boxes.grill_box;
        Behavior.SubBehavior(2).qstart = [];
        Behavior.SubBehavior(2).qend = [];
        Behavior.SubBehavior(2).dqstart = [];
        Behavior.SubBehavior(2).dqend = [];
        Behavior.SubBehavior(3).name = 'scoop';
        Behavior.SubBehavior(3).description = 'scoop_the_burger';
        Behavior.SubBehavior(3).pose_start = pose_approach;
        Behavior.SubBehavior(3).pose_end = pose_burger;
        Behavior.SubBehavior(3).box = boxes.grill_box;
        Behavior.SubBehavior(3).qstart = [];
        Behavior.SubBehavior(3).qend = [];
        Behavior.SubBehavior(3).dqstart = [];
        Behavior.SubBehavior(3).dqend = [];
        Behavior.SubBehavior(4).name = 'pickup';
        Behavior.SubBehavior(4).description = 'pickup_the_burger';
        Behavior.SubBehavior(4).pose_start = pose_burger;
        Behavior.SubBehavior(4).pose_end = pose_pickup;
        Behavior.SubBehavior(4).box = boxes.grill_box;
        Behavior.SubBehavior(4).qstart = [];
        Behavior.SubBehavior(4).qend = [];
        Behavior.SubBehavior(4).dqstart = [];
        Behavior.SubBehavior(4).dqend = [];
        Behavior.SubBehavior(5).name = 'flipdrop';
        Behavior.SubBehavior(5).description = 'flip_the_burger';
        Behavior.SubBehavior(5).pose_start = pose_pickup;
        Behavior.SubBehavior(5).pose_end = pose_burger;
        Behavior.SubBehavior(5).box = boxes.grill_box;
        Behavior.SubBehavior(5).qstart = [];
        Behavior.SubBehavior(5).qend = [];
        Behavior.SubBehavior(5).dqstart = [];
        Behavior.SubBehavior(5).dqend = [];
        Behavior.SubBehavior(6).name = 'j2j';
        Behavior.SubBehavior(6).description = 'turn_spatula_back';
        Behavior.SubBehavior(6).pose_start = [];
        Behavior.SubBehavior(6).pose_end = pose_home;
        Behavior.SubBehavior(6).box = boxes.grill_box;
        Behavior.SubBehavior(6).qstart = [];
        Behavior.SubBehavior(6).qend = q_home;
        Behavior.SubBehavior(6).dqstart = [];
        Behavior.SubBehavior(6).dqend = [];
    else
        error('Either p_start or p_burger are outside the box limits');
    end
    
    if ~isInGrillBox(p_home,boxes.grill_box) || ~isInTableBox(p_home,boxes.table_box)
        error('p_home (spatula home position) should be in both grill and table boxes');
    end
    
    if numel(Behavior.sub_behavior_names)~=Behavior.nSubBehaviors
        error('Number of sub behavior names is not equal to nSubBehaviors');
    end
end