function T = twist_exp(V, theta)
            
    v = V(1:3);
    w = V(4:6);

    if norm(w) == 0 % w = [0,0,0]
        R = eye(3);
        p = theta.*v;
    else
        R = skew_exp(w,theta);
        S = skew(w);
        p = (eye(3) - R)*S*v + w*(transpose(w)*v)*theta;
    end
    T = rigid_homogenous(R,p);
end