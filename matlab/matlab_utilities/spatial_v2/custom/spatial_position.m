%> @brief spatial_position Compute the position of specific point 
%> using the SVA
%> @author Ayonga Hereid
function [h] = spatial_position(sva, q, ib, offset, tIndices,rIndices)


% Following RBDL, Kinematics.cc, CalcPointJacobian
% Get chain for current dof, tracing up parent list
es = false(1, sva.NB);
jb = ib;
while jb ~= 0
    es(jb) = true;
    jb = sva.parent(jb);
end
% Get chain indices in a collapsed list
jbs = find(es);
nj = length(jbs);


nBase = 6;
% Xup = zeros(nBase, nBase, sva.NB);
% Xbase = zeros(nBase, nBase, sva.NB);




% Compute Kinematics
for j = 1:nj
    i = jbs(j);
    [ XJ, ~ ] = jcalc( sva.jtype{i}, q(i) );
    % Body frame effect (XJ) orienting the base transform (Xtree)
    % Transforms parent frame -> current
    Xup(:,:,i) = XJ * sva.Xtree(:,:,i);
    
    lambda = sva.parent(i);
    if lambda == 0
        Xbase(:,:,i) = Xup(:,:,i);
        Xbase0(:,:,i) = sva.Xtree(:,:,i);
    else
        Xbase(:,:,i) = Xup(:,:,i) * Xbase(:,:,lambda);        
        Xbase0(:,:,i) = sva.Xtree(:,:,i) * Xbase0(:,:,lambda);
    end
end

[E,r] = plux(Xbase(:,:,ib));
E0    = plux(Xbase0(:,:,ib));

%%% TODO: make sure the following code is correct!!!!
R_0_hip = E'*E0;
yaw = atan2(R_0_hip(2,1),R_0_hip(1,1));
roll = atan2(R_0_hip(3,2),R_0_hip(3,3));
pitch = atan2(-R_0_hip(3,1)*cos(roll),R_0_hip(3,3));

theta = [roll;pitch;yaw];

pos = r + transpose(E)*offset;


h = [pos(tIndices);theta(rIndices)];

end

