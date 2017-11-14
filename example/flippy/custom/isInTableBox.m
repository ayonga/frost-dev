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