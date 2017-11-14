function Behavior = validateTranslateBehaviorBox(Behavior,boxes,pose_home,pose_start,pose_end)
    %% this function checks if p_start p_end are on table side or grill size
    
    p_start = pose_start.position;
    p_end = pose_end.position;
    p_home = pose_home.position;
    
    
    if isInGrillBox(p_start,boxes.grill_box) && isInGrillBox(p_end,boxes.grill_box)
        Behavior.nSubBehaviors = 1;
        Behavior.sub_behavior_names = {'trans'};
        Behavior.SubBehavior(1).name = 'trans';
        Behavior.SubBehavior(1).description = 'translate_within_grill';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_end;
        Behavior.SubBehavior(1).box = boxes.grill_box;
        Behavior.SubBehavior(1).qstart = [];
        Behavior.SubBehavior(1).qend = [];
        Behavior.SubBehavior(1).dqstart = [];
        Behavior.SubBehavior(1).dqend = [];
    elseif isInTableBox(p_start,boxes.table_box) && isInTableBox(p_end,boxes.table_box)
        Behavior.nSubBehaviors = 1;
        Behavior.sub_behavior_names = {'trans'};
        Behavior.SubBehavior(1).name = 'trans';
        Behavior.SubBehavior(1).description = 'translate_within_table';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_end;
        Behavior.SubBehavior(1).box = boxes.table_box;
        Behavior.SubBehavior(1).qstart = [];
        Behavior.SubBehavior(1).qend = [];
        Behavior.SubBehavior(1).dqstart = [];
        Behavior.SubBehavior(1).dqend = [];
    elseif isInGrillBox(p_start,boxes.grill_box) && isInTableBox(p_end,boxes.table_box)
        Behavior.nSubBehaviors = 2;
        Behavior.sub_behavior_names = {'trans','trans'};
        Behavior.SubBehavior(1).name = 'trans';
        Behavior.SubBehavior(1).description = 'grill_to_home';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_home;
        Behavior.SubBehavior(1).box = boxes.grill_box;
        Behavior.SubBehavior(1).qstart = [];
        Behavior.SubBehavior(1).qend = [];
        Behavior.SubBehavior(1).dqstart = [];
        Behavior.SubBehavior(1).dqend = [];
        Behavior.SubBehavior(2).name = 'trans';
        Behavior.SubBehavior(2).description = 'home_to_table';
        Behavior.SubBehavior(2).pose_start = pose_home;
        Behavior.SubBehavior(2).pose_end = pose_end;
        Behavior.SubBehavior(2).box = boxes.table_box;
        Behavior.SubBehavior(2).qstart = [];
        Behavior.SubBehavior(2).qend = [];
        Behavior.SubBehavior(2).dqstart = [];
        Behavior.SubBehavior(2).dqend = [];
    elseif isInTableBox(p_start,boxes.table_box) && isInGrillBox(p_end,boxes.grill_box)
        Behavior.nSubBehaviors = 2;
        Behavior.sub_behavior_names = {'trans','trans'};
        Behavior.SubBehavior(1).name = 'trans';
        Behavior.SubBehavior(1).description = 'table_to_home';
        Behavior.SubBehavior(1).pose_start = pose_start;
        Behavior.SubBehavior(1).pose_end = pose_home;
        Behavior.SubBehavior(1).box = boxes.table_box;
        Behavior.SubBehavior(1).qstart = [];
        Behavior.SubBehavior(1).qend = [];
        Behavior.SubBehavior(1).dqstart = [];
        Behavior.SubBehavior(1).dqend = [];
        Behavior.SubBehavior(2).name = 'trans';
        Behavior.SubBehavior(2).description = 'home_to_grill';
        Behavior.SubBehavior(2).pose_start = pose_home;
        Behavior.SubBehavior(2).pose_end = pose_end;
        Behavior.SubBehavior(2).box = boxes.grill_box;
        Behavior.SubBehavior(2).qstart = [];
        Behavior.SubBehavior(2).qend = [];
        Behavior.SubBehavior(2).dqstart = [];
        Behavior.SubBehavior(2).dqend = [];
    else
        error('Either p_start or p_end are outside the box limits');
    end
    
    if ~isInGrillBox(p_home,boxes.grill_box) || ~isInTableBox(p_home,boxes.table_box)
        error('p_home (spatula home position) should be in both grill and table boxes');
    end
end