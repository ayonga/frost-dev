function model = parse_urdf(urdf_file, options)
% This function parse the ROS URDF file into a matlab struct
%
% @todo This function need to be implemented soon 
%
% @note At this moment, this parser only support the 'link' and 'joint'
% elements in the URDF file. More options are coming soon ...
%
% Parameters:
% urdf_file: the URDF file full path @type char
% 
% Return values:
% robot: a matlab struct that contains parsed robot parameters from the
% URDF file. @type struct

urdf = xmlread(urdf_file);

xml_robot = urdf.getElementsByTagName('robot').item(0);
assert(~isempty(xml_robot),['The provided URDF file does not contains ',...
    'the proper robot element. Please provide the correct file.']);

% extract rigid links
xml_links = xml_robot.getElementsByTagName('link');

num_links = xml_links.getLength();
links = struct();
for i=0:num_links-1
    xml_link = xml_links.item(i);
    links(i+1).name = xml_link.getAttribute('name');
    inertial = xml_link.getElementByTagName('inertial');
    origin = inertial.getElementByTagName('origin');
    mass   = inertial.getElementByTagName('mass');
    inertia   = inertial.getElementByTagName('inertia');
    
    xyz = origin.getAttribute('xyz');
    rpy = origin.getAttribute('rpy');
    
    
    links(i+1).mass = mass.getAttribute('value')
end



% extract joints
xml_joints = xml_robot.getElementsByTagName('joints');

    


model = struct();

error('Cannot support URDF file type at this moment.');




end

