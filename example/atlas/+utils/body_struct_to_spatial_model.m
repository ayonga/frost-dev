%> @brief Convert body struct to a spatial_v2 model
%> The purose of this is to facility an ease of conversion between
%> spatial_v2 and RBDL via files read in by yaml
function [model] = body_struct_to_spatial_model(robot, gravity)

if nargin < 2
    gravity = -9.81;
end

% dim = body_struct.dim; % @todo Add in option for planar
bodies = robot.Joints;
NB = length(bodies);
blankc = cell(NB, 1);
blankm = zeros(NB, 1);

model = struct();
% Fields for spatial_v2
model.type = 'spatial';
model.NB = NB;
model.parent = blankm;
model.jtype = blankc;
model.Xtree = blankc;
model.I = blankc;
model.mass = blankm;
model.gravity = [0, 0, gravity];

% Additional fields for kinematics
model.name = blankc;
model.axis_index = blankm;
model.is_revolute = blankm;
axes = 'xyz';

for i = 1:NB
    body = bodies(i);
    reference = body.Reference;
    lambda = getJointIndices(robot, reference.Name);
    
    model.parent(i) = lambda;
    
    index = find(body.Axis);
    assert(isscalar(index));
    axis_value = body.Axis(index);
    
    if strcmpi(body.Type,'revolute') || strcmpi(body.Type,'continuous')
        model.is_revolute(i) = true;
        prefix = 'R';
    else
        prefix = 'P';
    end
    if axis_value < 0
        jtype = ['-', prefix, axes(index)];
    else
        jtype = [prefix, axes(index)];
    end
    
    model.jtype{i} = jtype;
    model.Xtree{i} = plux(body.R, body.Offset);
    
    child_link_idx = getLinkIndices(robot, body.Child);
    
    if ~isnan(child_link_idx)        
        link = robot.Links(child_link_idx);
        model.I{i} = mcI(link.Mass, link.Offset, link.Inertia);
        model.mass(i) = link.Mass;
    else
        model.I{i} = mcI(0, zeros(3,1), zeros(3));
        model.mass(i) = 0;
    end
    model.name{i} = body.Name;
    model.axis_index(i) = index;
end

end
