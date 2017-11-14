function nlp = configureFlippyConstraints(nlp,bounds,sub_behavior)
    sub_behavior_name = sub_behavior.name;
    pose_start = sub_behavior.pose_start;
    pose_end = sub_behavior.pose_end;
    qstart = sub_behavior.qstart;
    qend = sub_behavior.qend;
    dqstart = sub_behavior.dqstart;
    dqend = sub_behavior.dqend;
    
    switch(sub_behavior_name)
        case 'j2j'
            nlp = joint2joint(nlp,bounds,qstart,qend,dqstart,dqend);
        case 'trans'
            nlp = translate(nlp,bounds,pose_start,pose_end,qstart,qend,dqstart,dqend);
        case 'p2p'
            nlp = pose2pose(nlp,bounds,pose_start,pose_end,qstart,qend,dqstart,dqend);
        case 'scoop'
            nlp = scoop(nlp,bounds,pose_start,pose_end,qstart,qend,dqstart,dqend);
        case 'pickup'
            nlp = pickup(nlp,bounds,pose_start,pose_end,qstart,qend,dqstart,dqend);
        case 'flipdrop'
            nlp = flipdrop(nlp,bounds,pose_start,pose_end,qstart,qend,dqstart,dqend);
        case default
            error('No matching sub behavior type found');
    end
    
end