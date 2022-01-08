function R = skew_exp(v, theta)
            

    S = skew(v);
    R = eye(3) + sin(theta)*S + (1-cos(theta)) * (S * S);
end