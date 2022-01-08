function gst = rigid_inverse(g)

    R = rigid_orientation(g);
    p = rigid_position(g);


    gst = [transpose(R),-transpose(R)*p;
        zeros(1,3),1];

end