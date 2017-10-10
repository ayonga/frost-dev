function Behavior = validateBehaviorBox(Behavior,boxes,pose_home,pose_start,pose_end)
    %% this function checks if p_start p_end are on table side or grill size
    
    p_start = pose_start.position;
    p_end = pose_end.position;
    p_home = pose_home.position;
    
    
    if isInGrillBox(p_start,boxes.grill_box) && isInGrillBox(p_end,boxes.grill_box)
        Behavior.nSubBehaviors = 1;
        Behavior.sub_behavior_names = {'trans'};
        Behavior.SubBehavior(1).name = 'translate_within_grill';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_end;
        Behavior.SubBehavior(1).box = boxes.grill_box;
    elseif isInTableBox(p_start,boxes.table_box) && isInTableBox(p_end,boxes.table_box)
        Behavior.nSubBehaviors = 1;
        Behavior.sub_behavior_names = {'trans'};
        Behavior.SubBehavior(1).name = 'translate_within_table';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_end;
        Behavior.SubBehavior(1).box = boxes.table_box;
    elseif isInGrillBox(p_start,boxes.grill_box) && isInTableBox(p_end,boxes.table_box)
        Behavior.nSubBehaviors = 2;
        Behavior.sub_behavior_names = {'trans','trans'};
        Behavior.SubBehavior(1).name = 'grill_to_home';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_home;
        Behavior.SubBehavior(1).box = boxes.grill_box;
        Behavior.SubBehavior(2).name = 'home_to_table';
        Behavior.SubBehavior(2).pose_start = pose_home;
        Behavior.SubBehavior(2).pose_end = pose_end;
        Behavior.SubBehavior(2).box = boxes.table_box;
    elseif isInTableBox(p_start,boxes.table_box) && isInGrillBox(p_end,boxes.grill_box)
        Behavior.nSubBehaviors = 2;
        Behavior.sub_behavior_names = {'trans','trans'};
        Behavior.SubBehavior(1).name = 'table_to_home';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_home;
        Behavior.SubBehavior(1).box = boxes.table_box;
        Behavior.SubBehavior(2).name = 'home_to_grill';
        Behavior.SubBehavior(2).pose_start = pose_home;
        Behavior.SubBehavior(2).pose_end = pose_end;
        Behavior.SubBehavior(2).box = boxes.grill_box;
    else
        error('Either p_start or p_end are outside the box limits');
    end
    
    if ~isInGrillBox(p_home,boxes.grill_box) || ~isInTableBox(p_home,boxes.table_box)
        error('p_home (spatula home position) should be in both grill and table boxes');
    end
end

function ret = isInGrillBox(p,grill_box)
    px  = p(1);
    py  = p(2);
    pz  = p(3);
    
    pxmin = grill_box.p_min(1);
    pymin = grill_box.p_min(2);
    pzmin = grill_box.p_min(3);
    
    pxmax = grill_box.p_max(1);
    pymax = grill_box.p_max(2);
    pzmax = grill_box.p_max(3);
    
    if px > pxmin && py > pymin && pz > pzmin && px < pxmax && py < pymax && pz < pzmax
        ret = true;
    else
        ret = false;
    end
end

function ret = isInTableBox(p,table_box)
    px  = p(1);
    py  = p(2);
    pz  = p(3);
    
    pxmin = table_box.p_min(1);
    pymin = table_box.p_min(2);
    pzmin = table_box.p_min(3);
    
    pxmax = table_box.p_max(1);
    pymax = table_box.p_max(2);
    pzmax = table_box.p_max(3);
    
    if px > pxmin && py > pymin && pz > pzmin && px < pxmax && py < pymax && pz < pzmax
        ret = true;
    else
        ret = false;
    end
end
