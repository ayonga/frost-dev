function gst = rigid_homogenous(R,p)
    % Convert a rotation + translation to a homogeneous matrix
    % if isrow(p)
    %     p = p';
    % end
    gst = [...
        R     p;
        0 0 0 1];
end