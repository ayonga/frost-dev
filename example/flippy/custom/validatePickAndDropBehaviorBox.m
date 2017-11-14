function Behavior = validatePickAndDropBehaviorBox(Behavior, boxes, pose_home, pose_start, pose_burger, pose_drop)
    %% this function checks if p_start p_end are on table side or grill size
    
    p_start = pose_start.position;
    p_burger = pose_burger.position;
    p_home = pose_home.position;
    p_drop = pose_drop.position;
    
    q_home = getHomeConfiguration();
    
    %% basic checks
    if ~isInGrillBox(p_home,boxes.grill_box) || ~isInTableBox(p_home,boxes.table_box)
        error('p_home (spatula home position) should be in both grill and table boxes');
    end

    %%
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
    
    if isInGrillBox(p_start,boxes.grill_box) && isInGrillBox(p_burger,boxes.grill_box) && isInTableBox(p_drop,boxes.table_box)
        Behavior.nSubBehaviors = 6;
        Behavior.sub_behavior_names = {'p2p','scoop','pickup','trans','trans','drop'};
        descriptions = {'translate_to_starting_position_for_pickup',...
                        'scoop_the_burger',...
                        'pickup_the_burger',...
                        'translate_to_home',...
                        'home_to_p_drop',...
                        'drop_the_burger'};
        start_poses = {pose_start,pose_approach,pose_burger,pose_pickup,pose_home,pose_drop};
        end_poses   = {pose_approach,pose_burger,pose_pickup,pose_home,pose_drop,pose_drop};
        boxes = {boxes.grill_box,boxes.grill_box,boxes.grill_box,boxes.grill_box,boxes.table_box,boxes.table_box};
        qstarts = {q_home,[],[],[],q_home,[]};
        qends = {[],[],[],q_home,[],[]};
        dqstarts = {[],[],[],[],[],[]};
        dqends = {[],[],[],[],[],[]};
        
    elseif isInTableBox(p_start,boxes.table_box) && isInGrillBox(p_burger,boxes.grill_box) && isInTableBox(p_drop,boxes.table_box)
        Behavior.nSubBehaviors = 7;
        Behavior.sub_behavior_names = {'trans','p2p','scoop','pickup','trans','trans','drop'};
        descriptions = {'translate_to_home',...
                        'translate_to_starting_position_for_pickup',...
                        'scoop_the_burger',...
                        'pickup_the_burger',...
                        'translate_to_home',...
                        'home_to_p_drop',...
                        'drop_the_burger'};
        start_poses = {pose_start,pose_home,pose_approach,pose_burger,pose_pickup,pose_home,pose_drop};
        end_poses   = {pose_home,pose_approach,pose_burger,pose_pickup,pose_home,pose_end,pose_drop};
        boxes = {boxes.table_box,boxes.grill_box,boxes.grill_box,boxes.grill_box,boxes.grill_box,boxes.table_box,boxes.table_box};
        qstarts = {[],q_home,[],[],[],q_home,[]};
        qends = {q_home,[],[],[],q_home,[],[]};
        dqstarts = {[],[],[],[],[],[],[]};
        dqends = {[],[],[],[],[],[],[]};
        
    else
        error('Either p_start or p_burger or p_drop are outside the box limits. Note: drop on grill is not supported yet');
    end
    
    Behavior.SubBehavior(Behavior.nSubBehaviors) = struct();
    for i=1:Behavior.nSubBehaviors
        Behavior.SubBehavior(i).name = Behavior.sub_behavior_names{i};
        Behavior.SubBehavior(i).description = descriptions{i};
        Behavior.SubBehavior(i).pose_start = start_poses{i};
        Behavior.SubBehavior(i).pose_end = end_poses{i};
        Behavior.SubBehavior(i).box = boxes{i};
        Behavior.SubBehavior(i).qstart = qstarts{i};
        Behavior.SubBehavior(i).qend = qends{i};
        Behavior.SubBehavior(i).dqstart = dqstarts{i};
        Behavior.SubBehavior(i).dqend = dqends{i};
    end
    
    %% some sanity check
    if numel(Behavior.sub_behavior_names)~=Behavior.nSubBehaviors
        error('Number of sub behavior names is not equal to nSubBehaviors');
    end
end