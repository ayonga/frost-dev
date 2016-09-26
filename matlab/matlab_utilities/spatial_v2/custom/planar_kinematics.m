%> @brief planar_kinematics Compute positions for kinematic values
%> @param Xbase cell array of NB transformations from world frame to the
%> jth body's frame. Compute from HandCKinematics
%> @param positions struct array of position configuration structs, of the
%> form struct('dof', index, 'offset', [x, y], 'name', 'string').
%> @return pos A 2 x n matrix of positions, with each column corresponding
%> to a struct in positions
%> @author Eric Cousineau <eacousineau@gmail.com>
function [pos] = planar_kinematics(Xbase, positions)

npos = length(positions);
pos = zeros(2, npos);
offsets = [positions.offset];
dofs = [positions.dof];

for i = 1:npos
    % See RBDL, CalcBodyToBaseCoordinates()
    X = plnr(0, offsets(:, i)) * Xbase(:,:,dofs(i));
    [~, r] = plnr(X);
    pos(:, i) = r;
end

end
