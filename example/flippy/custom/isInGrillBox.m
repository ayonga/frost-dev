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