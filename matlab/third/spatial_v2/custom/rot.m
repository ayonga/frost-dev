function out = rot(in)

% Isn't there already a function for this?
if size(in, 1) == 3
    out = blkdiag(in, in);
else
    out = in(1:3, 1:3);
end

end